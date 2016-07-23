# ******************************************************
#
# Name: FixtureList.pm
#
# 0.1  - 27 Jun 08 - POD added.
#
# ******************************************************

=head1 FixtureList.pm

=cut

{

  package FixtureList;

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

Constructor for the FixtureList object. Inherits from Parent.

=cut

  #***************************************
  sub new {

    #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    $self->initialise( \%args );
    $self->logger->debug("FixtureList object created.");

    return $self;
  }

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
    $self->logger->debug(Dumper $f);
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
    $self->logger->debug(Dumper $self->{FIXTURES});
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

=head2 output_html

Returns the HTML which displays the table with the current information for the division and week.

If results have been saved then that information is displayed. If not, the fixtures are displayed.

If the -form parameter is set then text input elements are displayed so that the information can be changed.

=cut

  #***************************************
  sub output_html {

    #***************************************
    my $self = shift;
    my $q    = $self->get_query;
    my $line;
    my %args = (@_);
    my $err=0;

    $self->set_division( $q->param("division") );
    $self->set_week( $q->param("matchdate") );

    my $fixtures = $self->_get_fixtures();

    my $system = $q->param("system");
    $line = $line
      . "\n<script language=\"JavaScript\" type=\"text/javascript\" src=\"menu_js.pl?system=$system&page=week_fixtures\"></script>\n\n";

    $line = $line . $self->get_heading( -form => $args{-form} );

    $line = $line . "<table class='week_fixtures'>\n";

    my $l = $q->th( { -class => "match_date" }, "Date" );
    $l = $l . $q->th("Home");
    $l = $l . $q->th("Away");

    $line = $line . $q->Tr($l) . "\n";
    my $dates = $self->{FIXTURES}->get_date_list();
    $self->logger->debug(Dumper $dates);

    foreach my $d (@$dates) {
	    my $fixtures_for_week = $self->{FIXTURES}->get_week_fixtures(-date => $d);
	    $self->logger->debug(Dumper $fixtures_for_week);
	    foreach my $f (@$fixtures_for_week){
	      my $cells = $q->td($d).$q->td($f->{home}).$q->td($f->{away});
	      my $row = $q->Tr($cells);
	      $line .= $row;
	    }
	    my $blanks =  $q->td('&nbsp;').$q->td('&nbsp;').$q->td('&nbsp;');
	    my $row = $q->Tr($blanks);
	    $line .= $row;
    }

    $line = $line . "</table>\n";

    return ($err, $line);

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

    # Loop through the labels eg "team", "played", "result", "runs", "wickets"
    my @labels;
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

=head2 save_results

Check the password and save the results if the password is correct.

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
    my $f;
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
