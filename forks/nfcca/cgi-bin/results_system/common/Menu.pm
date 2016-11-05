# ***************************************************************************
#
# Name: Menu.pm
#
# 0.1  - 25 Jun 08 - POD updated.
#
# ***************************************************************************

{

  package Menu;

  use strict;
  use CGI;

  use ResultsConfiguration;
  use Parent;

  our @ISA;
  unshift @ISA, "Parent";

=head1 Menu.pm

This package contains the code for the Menu object. The Menu object produces the HTML code
for the menu page.

=cut

=head1 Methods

=cut

=head2 new

This is the constructor for a Menu object. It inherits
its parameters from Parent. The most common are -query
and -config.

$m = Menu->new( -query => $q, -config => $c );

=cut

  #***************************************
  sub new {

    #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    $self->initialise( \%args );
    $self->logger->debug("Menu object created.");

    return $self;
  }

=head2 _return_to_link

Internal method which returns the html for the link which returns
the user to the calling page. The link is enclosed within a paragraph tag.
The text and href are read from the configuration file.

print $m->_return_to_link;

=cut

  #***************************************
  sub _return_to_link {

    #***************************************
    my $self = shift;
    my $q    = $self->get_query;
    my $line;
    my ( $l, $t ) = $self->get_configuration->get_return_page;
    $l = "javascript: parent.location.href=\'$l\';";
    if ( $l && $t ) {
      $line = $q->a( { -href => $l }, $t );
      $line = $q->p($line);
    }
    else {
      $self->logger->debug("No return information for menu page (href and title). $l $t");
    }
    return $line;
  }

=head2 output_html

This method returns the html for the menu page. No header or footer.

 print $q->header;
 print $q->start_html;
 print $m->output_html;
 print $q->end_html;

=cut

  #***************************************
  sub output_html {

    #***************************************
    my $self = shift;
    my $q    = $self->get_query;
    my $line;

    my $c      = $self->get_configuration;
    my $htdocs = $c->get_path( -htdocs => "Y", -allow_not_exists => "Y" ) . "/common";
    my $system = $q->param("system");
    $line = $line
      . "<script language=\"JavaScript\" type=\"text/javascript\" src=\"menu_js.pl?system=$system\"></script>\n";
    $line = $line
      . "<script language=\"JavaScript\" type=\"text/javascript\" src=\"$htdocs/menu.js\"></script>\n";

    $line = $line . "<h1>Results System</h1>\n";
    $line = $line
      . "<form id=\"menu_form\" name=\"menu_form\" method=\"post\" action=\"results_system.pl\"\n";
    $line = $line . " target = \"f_detail\">\n";
    $line = $line . "<select id=\"division\" name=\"division\" size=\"1\" onchange=\"add_dates();\">\n";
    $line = $line . "</select>\n";
    $line = $line . "<select id=\"matchdate\" name=\"matchdate\" size=\"1\">\n";
    $line = $line . "</select>\n";
    $line = $line . "<input type=\"submit\" value=\"Display Fixtures\"></input>\n";
    $line = $line
      . "<input type=\"hidden\" id=\"page\" name=\"page\" value=\"week_fixtures\"></input>\n";
    $line =
        $line
      . "<input type=\"hidden\" id=\"system\" name=\"system\" value=\""
      . $q->param("system")
      . "\"></input>\n";
    $line = $line . "</form>\n";

    $line = $line . "<script language=\"JavaScript\" type=\"text/javascript\">\n";
    $line = $line . "gFirstSaturday='30 April 2016'; gLastSaturday='3 Sep 2016';\n";
    $line = $line . "</script>\n";
    $line = $line . $self->_return_to_link;
    return ( 0, $line );

  }

  1;

}
