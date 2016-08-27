# ******************************************************
#
# Name: FixtureList.pm
#
#
# ******************************************************

=head1 FixtureList.pm

Returns an HTML page containing the fixtures for a division for the current season.

my $list = FixtureList->new( -query => $q, -config => $c );

my $html = $list->output_html();

  New Forest Colts Cricket Association 2016
 
  Fixtures For Division U9S
  
  Date	        Home	        Away
  
  7-May	        Langley Manor 1	Lymington 1
  7-May	        Hythe & Dibden	Fawley
  7-May	        Lymington 2	New Milton
  7-May	        Pylewell Park	Bashley
   	 	 
  14-May	Fawley	        Langley Manor 1
  14-May	Bashley	        Lymington 2
  14-May	New Milton	Hythe & Dibden
  14-May	Lymington 1	Pylewell Park
 	 	 
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

=head1 Public Methods

=cut

=head2 new

Constructor for the FixtureList object. Inherits from FileRenderer.

eg 

my $list = FixtureList->new( -query => $q, -config => $c );

where

-query = CGI object. Must contain the parameter "division".

-config = ResultsConfiguration object

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

=head2 output_html

Returns the HTML which displays the table with the current information for the division.

If results have been saved then that information is displayed. If not, the fixtures are displayed.

If the -form parameter is set then text input elements are displayed so that the information can be changed.

$html = $fl->output_html();

    <h1>New Forest Colts Cricket Association 2016</h1>
    <h1>Fixtures For Division U9S</h1>
    <table class='week_fixtures'>
        <tr>
            <th class="match_date">Date</th>
            <th>Home</th>
            <th>Away</th>
        </tr>
        <tr>
            <td>7-May</td>
            <td>Langley Manor 1</td>
            <td>Lymington 1</td>
        </tr>
        <tr>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
            <td>&nbsp;</td>
        </tr>
        <tr>
            <td>14-May</td>
            <td>Fawley</td>
            <td>Langley Manor 1</td>
        </tr>
        <tr>
            <td>14-May</td>
            <td>Bashley</td>
            <td>Lymington 2</td>
        </tr>
    </table>

=cut

  #***************************************
  sub output_html {

    #***************************************
    my $self = shift;
    my $q    = $self->get_query;
    my $line;
    my $err = 0;

    $self->set_division( $q->param("division") );

    my $fixtures = $self->_get_fixtures();

    my $system = $q->param("system");
    $line = $line
      . "\n<script language=\"JavaScript\" type=\"text/javascript\" src=\"menu_js.pl?system=$system&page=fixture_list\"></script>\n\n";

    $line = $line . $self->_get_heading();

    $line = $line . "<table class='week_fixtures'>\n";

    my $l = $q->th( { -class => "match_date" }, "Date" );
    $l = $l . $q->th("Home");
    $l = $l . $q->th("Away");

    $line = $line . $q->Tr($l) . "\n";
    my $dates = $self->{FIXTURES}->get_date_list();
    $self->logger->debug( Dumper $dates);

    foreach my $d (@$dates) {
      my $fixtures_for_week = $self->{FIXTURES}->get_week_fixtures( -date => $d );
      $self->logger->debug( Dumper $fixtures_for_week);
      foreach my $f (@$fixtures_for_week) {
        my $cells = $q->td($d) . $q->td( $f->{home} ) . $q->td( $f->{away} );
        my $row   = $q->Tr($cells);
        $line .= $row;
      }
      my $blanks = $q->td('&nbsp;') . $q->td('&nbsp;') . $q->td('&nbsp;');
      my $row    = $q->Tr($blanks);
      $line .= $row;
    }

    $line = $line . "</table>\n";

    return ( $err, $line );

  }

=head1 Private Methods

=cut

=head2 _get_fixtures

Returns the fixtures object for the division. Returns 1 on error
and a fixtures object on success.

$fixtures = $seld->_get_fixtures();

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
    $self->logger->debug( Dumper $self->{FIXTURES} );
    return $self->{FIXTURES};
  }

=head2 _get_heading

Returns an HTML string with a heading in it.

$h = $self->_get_heading();

=cut

  #***************************************
  sub _get_heading {

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

    my $f = "Fixtures";

    $line = $line . "<h1>$f For Division " . $name->{menu_name} . "</h1>\n";

    return $line;
  }

  1;

}
