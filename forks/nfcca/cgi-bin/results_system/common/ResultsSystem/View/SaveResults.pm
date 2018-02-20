package ResultsSystem::View::SaveResults;

=head1 ResultsSystem::View::SaveResults

=cut

use strict;
use warnings;

use ResultsSystem::View;
use parent qw/ ResultsSystem::View/;

=head1 External Methods (Public)

=cut

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger} = $args->{-logger} if $args->{-logger};
  return $self;
}

# TODO print $q->header( -expires => "+2d" );

=head2 run

=cut

sub run {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  my $html = $self->get_html;

  $html = $self->merge_content( $html, $data );

  $html = $self->merge_content( $self->html_wrapper, { CONTENT => $html } );

  $self->render( { -data => $html } );
}

=head1 Internal Methods (Private)

=cut

=head2 get_html

=cut

#***************************************
sub get_html {

  #***************************************
  my $self = shift;

  my $html = q{
    <script language="JavaScript" type="text/javascript" src="results_system.pl?system=[% SYSTEM %]&page=menu_js"></script>
    <script language="JavaScript" type="text/javascript" src="[% HTDOCS %]/menu.js"></script>

    <h1>Results System</h1>
    <form id="menu_form" name="menu_form" method="post" action="results_system.pl" target = "f_detail">
      <select id="division" name="division" size="1" onchange="add_dates();">
    </select>
    <select id="matchdate" name="matchdate" size="1">
    </select>
    <input type="submit" value="Display Fixtures"></input>
    <input type="hidden" id="page" name="page" value="week_fixtures"></input>
    <input type="hidden" id="system" name="system" value="[% SYSTEM %]"></input>
    </form>

    <script language="JavaScript" type="text/javascript">
    gFirstSaturday='30 April 2016'; gLastSaturday='3 Sep 2016';
    </script>
    <a href="javascript: parent.location.href='[% RETURN_TO_LINK %]'">[% RETURN_TO_TITLE %]</a>
};
  return $html;
}

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

1;

