# **********************************************************
#
# Name: LeagueTable.pm
#
# 0.1  - 24 Jun 08 - POD added. Debugged 000002.
# 0.2  - 27 Jun 08 - It is now an error if there are no week files. 000003.
# 0.3  - 01 Jul 08 - Sort by average or points. 000004.
#
# **********************************************************

{

  package LeagueTable;

  use strict;
  use CGI;
  use List::MoreUtils qw / first_index /;
  use Sort::Maker;

  use ResultsConfiguration;
  use FileRenderer;
  use WeekData;
  use Fixtures;
  use Data::Dumper;

  our @ISA;
  unshift @ISA, "FileRenderer";

=head2 Error Levels

 0 - Subroutine Entry/Exit
 1 - General Progress
 2 - Progress Tracking
 3 - Warning
 4 -
 5 - Fatal Error

Levels 2 to 5 will routinely be printed to log file.

=cut

=head1 Methods

=cut

=head2 new

This is the constructor for a LeagueTable object. It inherits from Parent.pm, so it can
accept the standard arguments of a Parent object. The two most important are -query and
-config.

 my $l = LeagueTable->new( -query => $q, -config => $c );
 $err = $l->create_league_table_file;
 $u->eAppend( \$l->eGetError );

=cut

  #***************************************
  sub new {

    #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    $self->initialise( \%args );
    $self->logger->debug("LeagueTable object created.");

    return $self;
  }

=head2 _get_all_week_files

Reads all the files in the csv directory specified in the configuration. It then loads all those
that match the specified pattern into a list.

It is assumed that there is a relationship between the name of the csv file of the division and the
names of the week files for that division. Specifically, the name of a week file will be produced by
removing the extension from the csv filename, adding an underscore and the date for the week. So
County1.csv has associated week files called County1_21-Jun.dat, County1_28-Jun.dat, etc.

This method selects the week files by using a pattern which consists of the csv basename plus an underscore.
Thus the pattern for "County1.csv" is "County1_".

The method returns an error code and a reference to the list of week files.

  ( $err, $list_ref ) = $lt->_get_all_week_files();

=cut

  #***************************************
  sub _get_all_week_files {

    #***************************************
    my $self = shift;
    my ( $FP, @files );
    my $err    = 0;
    my $csv    = $self->get_division;
    my $c      = $self->get_configuration;
    my $dir    = $c->get_path( -csv_files => "Y" );
    my $season = $c->get_season;
    $dir = "$dir/$season";

    if ( !-d $dir ) {
      $self->logger->debug("Directory for csv files not found.");
      $err = 1;
    }

    if ( $err == 0 ) {
      $csv =~ s/\..*$//g;    # Remove extension
      if ( !opendir $FP, $dir ) {
        $self->logger->debug("Unable to open directory $dir");
        $err = 1;
      }
    }

    if ( $err == 0 ) {
      @files = readdir $FP;
      $self->logger->debug( scalar(@files) . " files retrieved from $dir." );
      close $FP;
    }

    if ( $err == 0 ) {
      my $pattern = $csv . "_";
      @files = grep /^$pattern/, @files;
      $self->logger->debug( scalar(@files) . " of these files are week files for the division." );
    }

    return ( $err, \@files );

  }

=head2 _extract_data

This method accepts a reference to a list of week files. It then loops
through the files and creates a list of WeekData objects. Each WeekData
object contains the data for one week.

It returns an error code.

 $err = $lt->_extract_data( \@files );

=cut

  #***************************************
  sub _extract_data {

    #***************************************
    my $self      = shift;
    my $err       = 0;
    my $files_ref = shift;
    my $dir       = $self->get_configuration->get_path( -csv_files => "Y" );

    foreach my $f (@$files_ref) {

      my $wk = $f;
      $wk =~ s/^.*_(.*)\..*$/$1/;
      $self->logger->debug( "Create WeekData object " . $self->get_division . " $wk" );
      my $wd = WeekData->new(
        -config   => $self->get_configuration,
        -query    => $self->get_query,
        -division => $self->get_division,
        -week     => $wk
      );
      if ($wd) {
        $err = $wd->read_file;
        $self->eAppend( $wd->eGetError );
      }
      else {
        $self->logger->debug("Unable to create WeekData object.");
        $err = 1;
      }

      if ( $err == 0 ) {
        push @{ $self->{WEEKDATA} }, $wd;
      }

    }

    return $err;
  }

=head2 _get_all_week_data

Method which returns the list of WeekData objects.

 @all_wd = $self->_get_all_week_data;

=cut

  #***************************************
  sub _get_all_week_data {

    #***************************************
    my $self = shift;
    if ( $self->{WEEKDATA} ) {
      return @{ $self->{WEEKDATA} };
    }
  }

=head2 _process_data

This loops through the WeekData objects and creates a data structure for
the league table. The structure consists of an array of hash references.

 $err = $lt->_process_data;

=cut

  #***************************************
  sub _process_data {

    #***************************************
    my $self   = shift;
    my $err    = 0;
    my @all_wd = $self->_get_all_week_data;
    my @labels;
    my @table;

    if ( $all_wd[0] ) {
      @labels = $all_wd[0]->get_labels;
    }

    # Loop through all the week data objects.
    foreach my $wd (@all_wd) {

      my $lineno = 0;
      my $team   = "home";
      my $more   = 1;

      my $counter = 0;    # Guard against infinite loops.

      while ( $more == 1 && $counter < 1000 ) {

        # The processing finishes when there are no more lines
        # or the team name is undefined.
        my $fields_hash_ref = $wd->get_line($lineno);
        if ( !$fields_hash_ref ) {
          $more = 0;
          next;
        }
        my %fields_hash = %$fields_hash_ref;
        if ( !$fields_hash{team} ) {
          $more = 0;
          next;
        }

        # Find the row in the table for the current team.
        my $i = first_index { $_->{team} eq $fields_hash{team} } @table;

        # Create one if necessary
        if ( $i < 0 ) {
          my %h = ( team => $fields_hash{team} );
          $i = scalar(@table);
          $table[$i] = \%h;
        }

        foreach my $l (@labels) {

          # Skip if the match hasn't been played.
          if ( $fields_hash{played} !~ m/Y/i ) {
            last;
          }

          # Skip these fields because they play no part in the calculations.
          if ( $l =~ m/(performances)|(team)/ ) {
            next;
          }

          if ( $l =~ m/played/ ) {
            $table[$i]->{played} = $table[$i]->{played} + 1;
            next;
          }

          if ( $l eq "result" ) {
            if ( $fields_hash{result} =~ m/w/i ) {
              $table[$i]->{won} = $table[$i]->{won} + 1;
            }
            if ( $fields_hash{result} =~ m/t/i ) {
              $table[$i]->{tied} = $table[$i]->{tied} + 1;
            }
            if ( $fields_hash{result} =~ m/l/i ) {
              $table[$i]->{lost} = $table[$i]->{lost} + 1;
            }
            next;
          }

          # The rest of the fields are numeric so just add the new value to the previous value.
          $table[$i]->{$l} = $table[$i]->{$l} + $fields_hash{$l};

        }

        $counter++;
        $lineno++;

      }

      if ( $err == 0 ) {

        foreach my $t (@table) {

          $t->{average} = 0;
          if ( $t->{played} > 0 ) {

            $t->{average} = sprintf( "%.2f", $t->{totalpts} / $t->{played} );

          }

        }

      }

      if ( $err == 0 ) {
        $self->{AGGREGATED_DATA} = \@table;
      }

    }

    return $err;
  }

=head2 _get_aggregated_data

Method which returns a reference to the unsorted list of aggregated data.

 $aggregated_list_ref = $lt->_get_aggregated_data;
 print $aggregated_list_ref->[0]->{totalpts} . "\n";

=cut

  #***************************************
  sub _get_aggregated_data {

    #***************************************
    my $self = shift;
    return $self->{AGGREGATED_DATA};
  }

=head2 _sort_table

Method which sorts the aggregated data into descending order
by the total number of points.

The sorted data in placed in a new list.

  $err = $lt->_sort_table;

=cut

  #***************************************
  sub _sort_table {

    #***************************************
    my $self = shift;
    my $err  = 0;
    my @sorted;

    my $t_ref = $self->_get_aggregated_data;
    if ( !$t_ref ) {
      $self->logger->debug("_sort_table(): No aggregated data to sort.");
      if ( $self->_get_sorted_table ) {
        $self->logger->debug("_sort_table(): A sorted list of teams already exists.");
        return 0;
      }
      else {
        $self->("_sort_table(): No aggregated data and not list of teams.");
        return 1;
      }
    }
    my @table = @$t_ref;

    my $order = $self->get_configuration->get_calculation( -order_by => "Y" );
    if ( $order ne "average" ) {
      $order = "totalpts";
    }

    my $sorter = make_sorter( 'ST', 'descending', number => '$_->{' . $order . '}' );
    if ( !$sorter ) {
      $self->logger->debug( "Unable to create sorter. " . $@ );
      $err = 1;
    }

    if ( $err == 0 ) {
      @sorted = $sorter->(@table);
      $self->{SORTED_TABLE} = \@sorted;
    }

    return $err;

  }

=head2 _set_sorted_table

=cut

  #***************************************
  sub _set_sorted_table {

    #***************************************
    my $self = shift;
    $self->{SORTED_TABLE} = shift;
    return undef;
  }

=head2 _get_sorted_table

This method returns a reference to the table of sorted data.

 $sorted_ref = $lt->_get_sorted_table;
 print $sorted_ref->[0]->{team} . "\n";

=cut

  #***************************************
  sub _get_sorted_table {

    #***************************************
    my $self = shift;
    return $self->{SORTED_TABLE};
  }

=head2 _d

This method sets an undefined value to 0. $v = $lt->_d( $v );

=cut

  #***************************************
  # Sets undefined values to 0.
  #***************************************
  sub _d {

    #***************************************
    my $v = shift;
    return $v ? $v : 0;
  }

=head2 output_html

This method returns a string containing the html for a page containing
the league table. Includes the start and end html but not the header.

( $err, $line ) = $lt->output_html;
print $q->header . " " . $line . "\n";

=cut

  #***************************************
  sub output_html {

    #***************************************
    my $self  = shift;
    my $t_ref = $self->_get_sorted_table;
    my @table = @$t_ref;
    my ( $line, $row );
    my $err   = 0;
    my $q     = $self->get_query;
    my $order = $self->get_configuration->get_calculation( -order_by => "Y" );

    $line =
        $line
      . $q->th( { -class => "teamcol" }, "Team" )
      . $q->th("Played")
      . $q->th("Won")
      . $q->th("Tied")
      . $q->th("Lost")
      . $q->th("Batting Pts")
      . $q->th("Bowling Pts")
      . $q->th("Penalty Pts")
      . $q->th("Total");

    if ( $order eq "average" ) {

      $line = $line . $q->th( _d("Average") );

    }

    $line = $q->Tr($line) . "\n";

    foreach my $t (@table) {

      $row = $q->td( { -class => "teamcol" }, $t->{team} );
      $row = $row . $q->td( _d( $t->{played} ) );
      $row = $row . $q->td( _d( $t->{won} ) );
      $row = $row . $q->td( _d( $t->{tied} ) );
      $row = $row . $q->td( _d( $t->{lost} ) );
      $row = $row . $q->td( _d( $t->{battingpts} ) );
      $row = $row . $q->td( _d( $t->{bowlingpts} ) );
      $row = $row . $q->td( _d( $t->{penaltypts} ) );
      $row = $row . $q->td( _d( $t->{totalpts} ) );

      if ( $order eq "average" ) {

        $row = $row . $q->td( _d( $t->{average} ) );

      }

      $line = $line . $q->Tr($row) . "\n";

    }
    $line = $q->table( { -class => "league_table" }, $line );

    my $c = $self->get_configuration;

    my $p =
        $c->get_path( "-cgi-dir" => "Y" )
      . "/common/results_system.pl?page=tables_index&system="
      . $q->param("system");
    $line = $q->p( $q->a( { -href => $p }, "Return to Tables Index" ) ) . $line;

    my $division_name = $c->get_name( -csv_file => $self->get_division );
    if ($division_name) {
      $line = $q->h2( "Division: " . $division_name->{menu_name} ) . $line;
    }

    $line =
      $q->h1( $c->get_descriptors( -title => "Y" ) . " " . $c->get_descriptors( -season => "Y" ) )
      . $line;

    my $s = $self->_get_sheet( "table_dir", "web" );
    $s    = "/results_system_v2/custom/hcl/gen_styles.css";    # TODO
    $line = $q->start_html(
      -style => $s,
      -title => $c->get_descriptors( -title => "Y" )
      )
      . $line
      . $q->p( { -class => "timestamp" },
      my $t = localtime )    # Force localtime into scalar context.
      . $q->end_html;

    return ( $err, $line );
  }

=head2 write_file

This method writes the string passed as an argument to an HTML file. The filename
is formed by replacing the .csv for the csv file with .htm. The file will be written
to the directory given by "table_dir" in the configuration file.

 $err = $lt->write_file( $line );

=cut

  #***************************************
  sub write_file {

    #***************************************
    my $self = shift;
    my $line = shift;
    my $err  = 0;
    my ( $f, $FP );
    my $c = $self->get_configuration;
    my $dir = $c->get_path( -table_dir_full => "Y" );

    if ( !-d $dir ) {
      $self->logger->debug("Table directory $dir does not exist.");
      $err = 1;
    }
    if ( !$line ) {
      $self->logger->debug("No data passed to write_file.");
      $err = 1;
    }

    $f = $self->get_division;    # The csv file
    $f =~ s/\..*$/\.htm/;        # Change the extension to .htm
    $f = "$dir/$f";              # Add the path

    if ( $err == 0 ) {
      if ( !open( $FP, ">", $f ) ) {
        $self->logger->debug("Unable to open file $f for writing.");
        $err = 1;
      }
    }
    if ( $err == 0 ) {
      print $FP $line;
      close $FP;
    }
    return $err;
  }

=head2 create_league_table_file

This method runs all the other methods necessary to write an updated league
table to the HTML file.

 $err = $lt->create_league_table_file;

=cut

  #***************************************
  sub create_league_table_file {

    #***************************************
    my $self = shift;
    my $err  = 0;
    my ( @files, $files_ref, $line );
    my $is_week_data = 1;

    if ( !$self->get_division ) {
      $self->logger->debug("Division not set.");
      $err = 1;
    }

    if ( $err == 0 ) {
      ( $err, $files_ref ) = $self->_get_all_week_files;
      @files = @$files_ref;
    }

    if ( $err == 0 && scalar(@files) == 0 ) {
      $self->logger->debug(
        "No week files found. Cannot produce table. Use teams in fixture list.");
      $is_week_data = 0;
      my $csv    = $self->get_division;
      my $season = $self->get_configuration->get_season;
      my $dir    = $self->get_configuration->get_path( -csv_files => "Y" );
      my $f      = Fixtures->new( -full_filename => "$dir/$season/$csv" );
      if ( !$f ) {
        $self->logger->debug("Unable to create Fixtures object.");
        $self->logger->debug($Fixtures::create_errmsg);
        $err = 1;
      }
      $self->_set_sorted_table( $f->get_all_teams ) if $err == 0;
    }

    if ( $err == 0 && $is_week_data ) {
      $err = $self->_extract_data( \@files );
    }

    if ( $err == 0 && $is_week_data ) {
      $err = $self->_process_data;
    }

    if ( $err == 0 && $is_week_data ) {
      $err = $self->_sort_table;
    }

    if ( $err == 0 ) {
      ( $err, $line ) = $self->output_html;
    }

    if ( $err == 0 ) {
      $err = $self->write_file($line);
    }

    if ( $err == 0 ) {
      $err = $self->_copy_stylesheet("table_dir");
    }

    my $c = $self->get_configuration;
    $self->eAppend( \$c->eGetError );
    return $err;
  }

  1;

}
