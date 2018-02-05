# ******************************************************
#
# Name: WeekFixtures.pm
#
# 0.1  - 27 Jun 08 - POD added.
#
# ******************************************************

=head1 WeekFixtures.pm

=cut

  package ResultsSystem::Model::WeekFixtures;

  use strict;
  use warnings;

  use Data::Dumper;

  use parent qw/ ResultsSystem::Model /;

=head1 Public Methods

=cut

=head2 new

=cut

  #***************************************
  sub new {

    #***************************************
    my ($class, $args)=@_;
    my $self = {};
    bless $self, $class;

    foreach my $a (qw/ logger configuration week_data fixtures /) {
      my $m = 'set_' . $a;
      my $k = '-'.$a;
      $self->$m($args->{$k});
    }

    $self->logger->debug("WeekFixtures object created.");

    return $self;
  }

=head2 output_html

Returns the HTML which displays the table with the current information for the division and week.

If results have been saved then that information is displayed. If not, the fixtures are displayed.

Parameters:

-form : If true then text input elements are displayed so that the information can be changed.

-no_link : If true then the "Return To Results Index" link is not displayed.


=cut

  #***************************************
  sub output_html {

    #***************************************
    my $self = shift;
    my $q    = $self->get_query;
    my $line;
    my %args = (@_);
    my $err  = 0;
    $self->set_division( $q->param("division") );
    $self->set_week( $q->param("matchdate") );

my $data = { system = $q->param("system"), division => $self->get_division, week => $self->get_week}:

    for ( my $x = 0; $x < 10; $x++ ) {

      $line = $line
        . $self->_fixture_line(
        -index => $x,
        -type  => "home",
        -query => $q,
        -form  => $args{-form}
        );
      $line = $line
        . $self->_fixture_line(
        -index => $x,
        -type  => "away",
        -query => $q,
        -form  => $args{-form}
        );
      $line = $line . $self->_blank_line( -index => $x, -type => "blank", -query => $q );

    }

    my $wd = $self->get_week_data;

    return ( $err, $line );

  }

=head2 save_results

Save the results if the password is correct.

$wf->save_results(-save_html => 1);

Must have been authorised elsewhere!

parameters:

-save_html : If true then save the results to file. If false, do all the checks
but don't save.

=cut

  #***************************************
  sub save_results {

    #***************************************
    my $self = shift;
    my %args = (@_);
    my $q    = $self->get_query;
    my $type = "home";
my $err = 0;

    if ( $err == 0 ) {

      $self->set_division( $q->param("division") );
      $self->set_week( $q->param("matchdate") );

      my $x = 0;
      while ( $x < 10 && $err == 0 ) {

        $err = $self->_save_line( -lineno => $x, -type => $type );

        if ( $type eq "home" ) {
          $type = "away";
        }
        else {
          $type = "home";
          $x++;
        }

      }

    }
    if ( $err == 0 ) {
      my $w = $self->_get_week_data;
      $w->set_division( $q->param("division") );
      $w->set_week( $q->param("matchdate") );
      $err = $w->write_file;
    }

    if ( $err == 0 && $args{-save_html} ) {
      $err = $self->_save_html();
    }

    return ( $err, $line );
  }

=head1 Private Methods

=cut

#=head2 _get_week_data
#
#Returns a WeekData object for the week and division.
#
#=cut
#
#  #***************************************
#  sub _get_week_data {
#
#    #***************************************
#    my $self = shift;
#    
#    if ( !$self->{WEEK_DATA} ) {
#      $self->{WEEK_DATA} = WeekData->new(
#        -week     => $self->get_week,
#        -division => $self->get_division,
#        -config   => $self->get_configuration,
#        -logger   => $self->logger
#      );
#      my $err = $self->{WEEK_DATA}->read_file;
#      if ( $err != 0 ) {
#        $self->logger->error("Error reading WeekDate.");
#      }
#    }
#    return $self->{WEEK_DATA};
#  }

=head2 _get_value_string

This attempts to retrieve the value from the WeekFixtures object. If no data has been saved
for the current week then it returns undefined for all fields except the team name, which is
retrieved from the fixture list.

 Called with 3 parameters: type, lineno and field.
 e.g. $w->get_value_string( "home", 0, "team" );
 
 Returns a string of the form "xxxxxxxxxxxx".
 Returns undef if the value is not found.

=cut

  #***************************************
  sub _get_value_string {

    #***************************************
    my $self = shift;
    my $t    = shift;
    my $l    = shift;
    my $f    = shift;
    my $obj  = $self->_get_week_data;
    my $v;

    $self->logger->debug("get_value_string called() $t $l $f");
    if ($obj) {

      $v = $obj->get_field(
        -type   => "match",
        -lineno => $l,
        -field  => $f,
        -team   => $t
      );
    }

    if ( ( $obj->file_not_found ) && ( $f eq "team" ) ) {
      $v = $self->_get_team_name( -type => "match", -lineno => $l, -team => $t );
    }

    if ($v) {
      $self->logger->debug("Leaving get_value_string(): $v");
      return $v;
    }

  }

=head2 _get_team_name

This function is called when there aren't any results for the division/week. It
accesses the fixture list and returns the team name from there.

 -team    : home or away
 -lineno  : The number of the fixture in the list. Zero based.
 -type    : match 

=cut

  #***************************************
  sub _get_team_name {

    #***************************************
    my $self = shift;
    my %args = (@_);
    my $n;
    $self->logger->debug("get_team_name() called.");

    my $f = $self->_get_fixtures;
    my $r = ref($f);
    if ( $r ne "Fixtures" ) {
      $self->logger->error( "Not a Fixtures object. " . $r );
      return undef;
    }
    my $week_ref = $f->get_week_fixtures( -date => $self->get_week );
    my @week = @$week_ref;
    $self->logger->debug($@);

    $self->logger->debug(
      scalar(@week)
        . " elements in list of fixtures. Looking for line "
        . $args{-lineno}
        . " team="
        . $args{-team},
      1
    );
    my $i = $args{-lineno};
    if ( $args{-type} eq "match" ) {
      if ( $args{-team} eq "away" ) {
        $n = $week[$i]->{away};
      }
      else {
        $n = $week[$i]->{home};
      }
    }
    return $n;
  }

=head2 _get_fixtures

Returns the fixtures object for the week and division. Returns 1 on error
and a fixtures object on success.

=cut

  #***************************************
  sub _get_fixtures {

    #***************************************
    my $self = shift;
    my $err  = 0;

    if ( !$self->{FIXTURES} ) {

      $self->logger->debug("get_fixtures(): About to create Fixtures object.");

      my $c = $self->get_configuration;

      my $d = $self->get_division;    # This is the csv file.
      $self->logger->debug( "division= " . $d );

      my $season = $c->get_season;
      $self->logger->debug("season= $season");

      my $ff = $c->get_path( -csv_files => 'Y' ) . "/" . $season . "/" . $d;
      $self->logger->debug( "Path to csv files=" . $c->get_path( -csv_files => 'Y' ) );

      $self->{FIXTURES} = Fixtures->new( -full_filename => $ff, -logger => $self->logger );
      if ( !$self->{FIXTURES} ) {
        $err = 1;
        $self->logger->error("get_fixtures() unable to create Fixtures object.");
        $self->logger->error($Fixtures::create_errmsg);
        return $err;
      }

    }
    return $self->{FIXTURES};
  }

=head2 _get_heading

Returns an HTML string with a heading in it.

=cut

  #***************************************
  sub get_heading {

    #***************************************
    my $self = shift;
    my $q    = $self->get_query;
    my $line;
    my %args = (@_);

    my $c = $self->get_configuration;
    my $name = $c->get_name( -csv_file => $self->get_division );
    $line =
        $line . "<h1>"
      . $c->get_descriptors( -title  => "Y" ) . " "
      . $c->get_descriptors( -season => "Y" ) . "</h1>";

    my $f = "Results";
    if ( $args{-form} ) {
      $f = "Fixtures";
    }

    $line =
        $line
      . "<h1>$f For Division "
      . $name->{menu_name}
      . " Week "
      . $self->get_week
      . "</h1>\n";

    return $line;
  }

=head2 _save_line
 
=cut

  #***************************************
  sub _save_line {

    #***************************************
    my $self = shift;
    my $q    = $self->get_query;
    my $line;
    my %args = (@_);
    my $err  = 0;
    my $obj  = $self->_get_week_data;

    my @labels = $obj->get_labels;

    # Loop through the labels eg "team", "played", "result", "runs", "wickets"
    foreach my $label (@labels) {

      my $v;

      # Construct the corresponding parameter/field name and get its value from the CGI.
      # eg homeplayed1 or team2. (Numbers start at 0.)
      if ( $label ne "team" ) {
        $v = $q->param( $args{-type} . $label . $args{-lineno} );
      }
      else {
        $v = $q->param( $args{-type} . "" . $args{-lineno} );
      }

      # Store the details in the WeekData object.
      $err = $obj->set_field(
        -value  => $v,
        -field  => $label,
        -team   => $args{-type},
        -lineno => $args{-lineno},
        -type   => "match"
      );
      if ( $err != 0 ) {
        $self->logger->debug(
          "save_line(): Unable to set field "
            . $args{-type} . " "
            . $label . " "
            . $args{-lineno} . "to "
            . $q->param( $args{-type} . $label . $args{-lineno} ),
          5
        );
        last;
      }

    }

    return $err;

  }

  #***************************************
  sub _save_html {

    #***************************************
    my $self = shift;
    my %args = (@_);
    my $err  = 0;
    my $FP;

    my $c = $self->get_configuration;
    my $s = $self->_get_sheet( "results_dir", "web" );

    # .dat file for week, no path
    my $f = $self->get_week_data->get_filename;
    $f =~ s/\.dat/\.htm/;

    my $path = $c->get_path( -results_dir_full => "Y" );
    if ( !$path ) {
      $self->logger->error("No path for results htm file. -results_dir");
      $err = 1;
    }

    if ( $err == 0 ) {
      $f = "$path/$f";
      if ( !open( $FP, ">", $f ) ) {
        $self->logger->error("Unable to open file $f");
        $err = 1;
      }
    }

    if ( $err == 0 ) {
      $err = $self->_copy_stylesheet("results_dir");
    }

    if ( $err == 0 ) {
      my $q = $self->get_query;
      print $FP $q->start_html(
        -style => $s,
        -title => $c->get_descriptors( -title => "Y" )
        )
        . "\n"
        . $self->output_html( -no_link => "Y" ) . "\n"
        . $q->end_html . "\n";
    }

    close $FP if $FP;

    return $err;

  }

=head3 set_week_data

=cut

sub set_week_data {
  my ($self,$v)=@_;
  $self->{WEEK_DATA}=$v;
  return $self;
}

=head3 get_week_data

=cut

sub get_week_data {
  my $self=shift;
  return $self->{WEEK_DATA};
}

=head3 set_fixtures

=cut

sub set_fixtures {
  my ($self,$v)=@_;
  $self->{FIXTURES}=$v;
  return $self;
}

=head3 get_fixtures

=cut

sub get_fixtures {
  my $self=shift;
  return $self->{FIXTURES};
}

  1;

