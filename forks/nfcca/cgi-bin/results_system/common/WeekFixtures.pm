# ******************************************************
#
# Name: WeekFixtures.pm
#
# 0.1  - 27 Jun 08 - POD added.
#
# ******************************************************

=head1 WeekFixtures.pm

=cut

{

  package WeekFixtures;

  use strict;
  use CGI;

  use ResultsConfiguration;
  use FileRenderer;
  use WeekData;
  use Fixtures;
  use Pwd;
  use Data::Dumper;

  our @ISA;
  unshift @ISA, "FileRenderer";

=head1 Public Methods

=cut

=head2 new

Constructor for the WeekFixtures object. Inherits from Parent.

=cut

  #***************************************
  sub new {

    #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    $self->initialise( \%args );
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

    my $system = $q->param("system");
    $line = $line
      . "\n<script language=\"JavaScript\" type=\"text/javascript\" src=\"menu_js.pl?system=$system&page=week_fixtures\"></script>\n\n";

    $line = $line . $self->get_heading( -form => $args{-form} );

    if ( !$args{-form} && !$args{-no_link} ) {
      my $s = "results_system.pl?system=" . $q->param("system") . "&page=results_index";
      $line = $line . $q->p( $q->a( { -href => $s }, "Return To Results Index" ) ) . "\n";
    }

    if ( $args{-form} ) {
      $line = $line
        . "<form id=\"menu_form\" name=\"menu_form\" method=\"post\" action=\"results_system.pl\"\n";
      $line = $line . " onsubmit=\"return validate_menu_form();\"\n";
      $line = $line . " target = \"f_detail\">\n";
    }
    $line = $line . "<table class='week_fixtures'>\n";

    my $l = $q->th( { -class => "teamcol" }, "Team" );
    $l = $l . $q->th("Played");
    $l = $l . $q->th("Result");
    $l = $l . $q->th("Runs");
    $l = $l . $q->th("Wickets");
    $l = $l . $q->th( { -class => "performances" }, "Performances" );
    $l = $l . $q->th("Result Pts");
    $l = $l . $q->th("Batting Pts");
    $l = $l . $q->th("Bowling Pts");
    $l = $l . $q->th("Penalty Pts");
    $l = $l . $q->th("Total Pts");
    $l = $l . $q->th("Pitch");
    $l = $l . $q->th("Outfield");
    $l = $l . $q->th("Facilities");

    $line = $line . $q->Tr($l) . "\n";

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

    $line = $line . "</table>\n";

    $line = $line
      . $q->input(
      { -type  => "hidden",
        -name  => "division",
        -id    => "division",
        -value => $self->get_division
      }
      ) . "\n";
    $line = $line
      . $q->input(
      { -type  => "hidden",
        -name  => "matchdate",
        -id    => "matchdate",
        -value => $self->get_week
      }
      ) . "\n";
    $line = $line
      . $q->input(
      { -type  => "hidden",
        -name  => "page",
        -id    => "page",
        -value => "save_results"
      }
      ) . "\n";
    $line = $line
      . $q->input(
      { -type  => "hidden",
        -name  => "system",
        -id    => "system",
        -value => $q->param("system")
      }
      ) . "\n";

    if ( $args{-form} ) {
      my $p = Pwd->new( -query => $q );
      $line = $line . $p->get_pwd_fields . "<br/>";
      $line = $line . $q->input( { -type => "submit", -value => "Save Changes" } ) . "<br/>\n";
      $line = $line . "</form>\n";
    }

    my $wd = $self->_get_week_data;

    return ( $err, $line );

  }

=head2 save_results

Check the password and save the results if the password is correct.

$wf->save_results(-save_html => 1);

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

    my $p = Pwd->new( -query => $q, -config => $self->get_configuration );
    my ( $err, $line ) = $p->check_pwd();

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

    if ( $err == 0 ) {
      $line = "<h3>Your changes have been accepted</h3>\n";
    }
    else {
      $line = $line . "<h3>Your changes have been rejected.</h3>\n";
    }

    if ( $err == 0 && $args{-save_html} ) {
      $err = $self->_save_html();
    }

    return ( $err, $line );
  }

=head1 Private Methods

=cut

=head2 _blank_line

Returns a string containing HTML. The HTML is a table row
with 11 cells. Each cell contains the &nbsp;

=cut

  #***************************************
  sub _blank_line {

    #***************************************
    my $self = shift;
    my %args = (@_);
    my $line;

    for ( my $x = 0; $x < 14; $x++ ) {
      if ( $x == 0 ) {
        $line = $line . $args{-query}->td( { -class => "teamcol" }, "&nbsp;" );
      }
      else {
        $line = $line . $args{-query}->td("&nbsp;");
      }
    }
    return $args{-query}->Tr($line) . "\n";
  }

=head2 _format_element

This method returns the HTML for a table data element.

If the parameter -form is set then the element will contain a text input element. Otherwise
it will just contain a value.

It accepts the following parameters:

 -form     : If this is true then an input element will be printed.
 -type     : Can be set to home or away.
 -name     : The name and id of the field. eg totalpts.
 -id       : The number of the field eg 2 for homebattingpts2
 -size     : Size of the input element.
 -value    : The value to be displayed.
 -readonly : True for a readonly field.

=cut

  #***************************************
  sub _format_element {

    #***************************************
    my $self = shift;
    my %args = (@_);
    my $line;
    my $i = $args{-index};
    my $v = $args{-value};
    my $q = $self->get_query;

    if ( $args{-form} ) {

      if ( $args{-name} eq "team" ) {
        $args{-name} = undef;
      }

      if ( $args{-name} !~ m/^(played)|(result)$/ ) {
        my %h = (
          -type     => 'text',
          -name     => $args{-type} . $args{-name} . $i,
          -id       => $args{-type} . $args{-name} . $i,
          -size     => $args{-size},
          -value    => "",
          -onChange => "calculate_points( this, $i )"
        );
        if ($v) {
          $h{-value} = $v;
        }
        if ( $args{-readonly} ) {
          $h{-readonly} = "readonly";
        }
        $line = $q->input( \%h );
      }
      else {

        if ( $args{-name} eq "played" ) {
          $line = $q->scrolling_list(
            -name    => $args{-type} . $args{-name} . $i,
            -id      => $args{-type} . $args{-name} . $i,
            -size    => 1,
            -values  => [ "Y", "N", "A" ],
            -default => $v ? $v : "N"
          );
        }
        else {
          $line = $q->scrolling_list(
            -name     => $args{-type} . $args{-name} . $i,
            -id       => $args{-type} . $args{-name} . $i,
            -size     => 1,
            -values   => [ "W", "L", "T" ],
            -onChange => "calculate_points( this, $i )",
            -default  => $v
          );
        }
      }
    }
    else {

      $line = $v;

    }
    my $class = $args{-name} eq "team" ? "teamcol" : $args{-name};
    $line = $q->td( { -class => $class }, $line );
    $line = $line . "\n";

    return $line;
  }

=head2 _fixture_line

Returns an HTML string containing a table row.

=cut

  #***************************************
  sub _fixture_line {

    #***************************************
    my $self = shift;
    my %args = (@_);
    my $line;
    my $q = $args{-query};
    my $i = $args{-index};
    my $v;

    my @elements = (
      { "name" => "team",         "size" => 32, "readonly" => "readonly" },
      { "name" => "played",       "size" => 2,  "readonly" => undef },
      { "name" => "result",       "size" => 2,  "readonly" => undef },
      { "name" => "runs",         "size" => 4,  "readonly" => undef },
      { "name" => "wickets",      "size" => 2,  "readonly" => undef },
      { "name" => "performances", "size" => 32, "readonly" => undef },
      { "name" => "resultpts",    "size" => 2,  "readonly" => undef },
      { "name" => "battingpts",   "size" => 2,  "readonly" => undef },
      { "name" => "bowlingpts",   "size" => 2,  "readonly" => undef },
      { "name" => "penaltypts",   "size" => 2,  "readonly" => undef },
      { "name" => "totalpts",     "size" => 2,  "readonly" => undef },
      { "name" => "pitchmks",     "size" => 2,  "readonly" => undef },
      { "name" => "groundmks",    "size" => 2,  "readonly" => undef },
      ,
      { "name" => "facilitiesmks", "size" => 2, "readonly" => undef }
    );

    $self->logger->debug("fixture_line() called.");

    foreach my $e (@elements) {

      $v = $self->_get_value_string( $args{-type}, $i, $e->{name} );
      if ( ( !defined($v) ) && ( !$args{-form} ) ) {
        $v = "&nbsp;";
      }
      $line = $line
        . $self->_format_element(
        -form     => $args{-form},
        -index    => $i,
        -value    => $v,
        -size     => $e->{size},
        -readonly => $e->{readonly},
        -type     => $args{-type},
        -name     => $e->{name}
        );

    }
    $line = $q->Tr($line) . "\n";

    return $line;

  }

=head2 _get_week_data

Returns a WeekData object for the week and division.

=cut

  #***************************************
  sub _get_week_data {

    #***************************************
    my $self = shift;
    if ( !$self->{WEEK_DATA} ) {
      $self->{WEEK_DATA} = WeekData->new(
        -week     => $self->get_week,
        -division => $self->get_division,
        -config   => $self->get_configuration
      );
      my $err = $self->{WEEK_DATA}->read_file;
      if ( $err != 0 ) {
        $self->logger->error("Error reading WeekDate.");
      }
    }
    return $self->{WEEK_DATA};
  }

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
    eval {
      # print "Append<br/>\n";
      # print $f->eDump . "<br/>\n";
    };
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

      $self->{FIXTURES} = Fixtures->new( -full_filename => $ff );
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
    my $f = $self->_get_week_data->get_filename;
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

  1;

}
