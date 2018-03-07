  package ResultsSystem::Model::LeagueTable;

  use strict;
  use warnings;
  use Clone qw/clone/;

  use List::MoreUtils qw / first_index /;
  use Sort::Maker;
  use Data::Dumper;

  use ResultsSystem::Model;
  use ResultsSystem::Exception;

  use parent qw/ResultsSystem::Model/;

=head1 NAME

ResultsSystem::Model::LeagueTable

=cut

=head1 SYNOPSIS

  my $l = ResultsSystem::Model::LeagueTable->new(-logger => $logger, 
                                                 -configuration => $configuration,
						 -fixtures_model => $f,
						 -week_data_reader_model => $wdm);
  $l->set_division( 'U9N.csv');
  $l->create_league_table;

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::Model

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

This is the constructor for a LeagueTable object.

  my $l = ResultsSystem::Model::LeagueTable->new(-logger => $logger, 
                                                 -configuration => $configuration
						 -fixtures_model => $f,
						 -week_data_reader_model => $wdm);
=cut

  #***************************************
  sub new {

    #***************************************
    my ( $class, $args ) = @_;
    my $self = {};
    bless $self, $class;
    $self->set_arguments( [qw/ configuration logger fixtures_model week_data_reader_model/],
      $args );

    # $self->logger->debug( Dumper $args);
    return $self;
  }

=head2 create_league_table

  gather_data
  _process_data
  _sort_table

=cut

  #***************************************
  sub create_league_table {

    #***************************************
    my $self = shift;

    $self->logger('Here');
    $self->gather_data();

    $self->_process_data;

    $self->_sort_table;

    return $self->_get_sorted_table;
  }

=head2 set_division

=cut

  sub set_division {
    my ( $self, $v ) = @_;
    $self->{division} = $v;
    return $self;
  }

=head2 get_division

=cut

  sub get_division {
    my $self = shift;
    die ResultsSystem::Exception->new( 'DIVISION_NOT_SET', 'The division has not been set.' )
      if !$self->{division};
    return $self->{division};
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

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

  $list_ref = $lt->_get_all_week_files();

=cut

  #***************************************
  sub _get_all_week_files {

    #***************************************
    my $self = shift;
    my ( $FP, @files );

    my $dir = $self->build_csv_path;

    my $csv = $self->get_division;
    $csv =~ s/\..*$//g;    # Remove extension

    opendir( $FP, $dir ) || do { die ResultsSystem::Exception->new( 'UNABLE_TO_OPEN_DIR', $! ); };

    @files = readdir $FP;
    $self->logger->debug( scalar(@files) . " files retrieved from $dir." );
    close $FP;

    my $pattern = $csv . "_";
    @files = grep /^$pattern/, @files;
    $self->logger->debug(
      scalar(@files) . " of these files are week files for the division. " . $csv );

    return \@files;

  }

=head2 build_csv_path

=cut

  sub build_csv_path {
    my $self = shift;
    my $c    = $self->get_configuration;

    my $dir = $c->get_path( -csv_files => "Y" );
    my $season = $c->get_season;
    $dir = "$dir/$season";

    die ResultsSystem::Exception->new( 'DIR_NOT_FOUND',
      "Directory for csv files not found. " . $dir )
      if !-d $dir;
    return $dir;
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
    my $files_ref = shift;
    my $dir       = $self->get_configuration->get_path( -csv_files => "Y" );
    $self->{WEEKDATA} = [];

    foreach my $f (@$files_ref) {

      my $wk = $f;
      $wk =~ s/^.*_(.*)\..*$/$1/;
      $self->logger->debug( "Create WeekData object " . $self->get_division . " $wk" );

      my $wd = $self->get_week_data_reader_model;
      $wd->set_division( $self->get_division );
      $wd->set_week($wk);
      $wd->read_file;

      push @{ $self->{WEEKDATA} }, clone $wd;

    }

    return 1;
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
    my @all_wd = $self->_get_all_week_data;
    my @labels;
    my @table = ();

    if ( $all_wd[0] ) {
      @labels = $all_wd[0]->get_labels;
    }

    # Loop through all the week data objects.
    foreach my $wd (@all_wd) {

      # $self->logger->debug( "Loop wd " . Dumper($wd) );

      my $lineno = 0;
      my $more   = 1;

      my $counter = 0;    # Guard against infinite loops.

      while ( $more == 1 && $counter < 1000 ) {

        # The processing finishes when there are no more lines
        # or the team name is undefined.
        my $fields_hash_ref = $wd->get_line($lineno);
        last if !$fields_hash_ref;
        last if !$fields_hash_ref->{team};

        $counter++;
        $lineno++;

        # Find the row in the table for the current team.
        my $i = first_index { $_->{team} eq $fields_hash_ref->{team} } @table;

        # Create one if necessary
        if ( $i < 0 ) {
          my $t = $self->get_new_table_row;
          $t->{team} = $fields_hash_ref->{team};
          push @table, $t;
          $i = scalar(@table) - 1;
        }

        # Skip these fields because they play no part in the calculations
        # and do not appear in the league table.
        @labels = grep {
          $_ !~ m/^(performances)|(team)|(runs)|(wickets)|(facilitiesmks)|(pitchmks)|(groundmks)$/
        } @labels;

        # Skip if the match hasn't been played.
        next if $fields_hash_ref->{played} !~ m/Y/i;

        $table[$i]->{played} += 1;

        $table[$i]->{won} += 1 if ( $fields_hash_ref->{result} =~ m/w/i );

        $table[$i]->{lost} += 1 if ( $fields_hash_ref->{result} =~ m/l/i );

        $table[$i]->{tied} += 1 if ( $fields_hash_ref->{result} =~ m/t/i );

        # The rest of the fields are numeric so just add the new value to the previous value.
        foreach my $k (qw /resultpts battingpts bowlingpts penaltypts totalpts/) {
          $table[$i]->{$k} = ( $table[$i]->{$k} || 0 ) + ( $fields_hash_ref->{$k} || 0 );

        }

      }

      foreach my $t (@table) {

        $t->{average} = 0;
        if ( ( $t->{played} || 0 ) > 0 ) {

          $t->{average} = sprintf( "%.2f", $t->{totalpts} / $t->{played} );

        }

      }

      $self->{AGGREGATED_DATA} = \@table;

    }

    return 1;
  }

=head2 get_new_table_row

=cut

  sub get_new_table_row {
    return {
      team         => "",
      played       => 0,
      won          => 0,
      tied         => 0,
      lost         => 0,
      performances => "",
      resultpts    => 0,
      battingpts   => 0,
      bowlingpts   => 0,
      penaltypts   => 0,
      totalpts     => 0,
      average      => 0
    };
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
    my @sorted;

    my $table = $self->_get_aggregated_data;
    die ResultsSystem::Exception->new( 'NO_AGGREGATED_DATA', 'No aggregated data to sort' )
      if !$table;

    my $order = $self->get_configuration->get_calculation( -order_by => "Y" );
    $order = "totalpts" if ( $order ne "average" );

    my $sorter = make_sorter( 'ST', 'descending', number => '$_->{' . $order . '}' );
    die ResultsSystem::Exception->new( 'NO_SORTER', "Unable to create sorter. " . $@ )
      if !$sorter;

    local $@;
    eval {
      @sorted = $sorter->(@$table);
      1;
    }
      || die ResultsSystem::Exception->new( 'BAD_SORT',
      "Unable to sort table. $@" . Dumper($table) );
    $self->{SORTED_TABLE} = \@sorted;

    $self->logger->debug( "Table sorted by $order " . Dumper( $self->{SORTED_TABLE} ) );
    return 1;

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

  #***************************************
  sub gather_data {

    #***************************************
    my $self = shift;
    my ( $files, $line );

    $files = $self->_get_all_week_files;

    if ( scalar(@$files) == 0 ) {
      $self->logger->debug(
        "No week files found. Cannot produce table. Use teams in fixture list.");

      my $csv = $self->get_division;
      $self->_set_sorted_table(
        $self->get_fixtures_model->set_full_filename( $self->build_csv_path . "/$csv" )
          ->get_all_teams );
    }
    else {
      $self->_extract_data($files);
    }
    return 1;
  }

=head2 set_fixtures_model

=cut

  sub set_fixtures_model {
    my ( $self, $v ) = @_;
    $self->{fixtures} = $v;
    return $self;
  }

=head2 get_fixtures_model

=cut

  sub get_fixtures_model {
    my $self = shift;
    return $self->{fixtures};
  }

=head2 set_week_data_reader_model

=cut

  sub set_week_data_reader_model {
    my ( $self, $v ) = @_;
    $self->{week_data_reader_model} = $v;
    return $self;
  }

=head2 get_week_data_reader_model

=cut

  sub get_week_data_reader_model {
    my $self = shift;
    return $self->{week_data_reader_model};
  }

  1;

