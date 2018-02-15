package ResultsSystem::View::Frame;

use strict;
use warnings;

use ResultsSystem::View;
use parent qw/ ResultsSystem::View/;

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger} = $args->{-logger} if $args->{-logger};
  return $self;
}

sub logger {
  my $self = shift;
  return $self->{logger};
}

# TODO print $q->header( -expires => "+2d" );

sub run {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  my $html = $self->get_html;

  $html = $self->merge_content( $html, $data );

  $html = $self->merge_content( $self->html_frame_wrapper,
    { CONTENT => $html, PAGETITLE => 'Results System', STYLESHEETS => "" } );

  $self->render( { -data => $html } );
}

=head2 get_html

=cut

sub get_html {

  my $output = qq{

  <frameset rows="30%,*">
  <frame noresize="noresize" src="[% MENU_PAGE %]" id = "f_menu"
    name="f_menu" scrolling="auto"></frame>
  <frame scrolling="auto" src="[% BLANK_PAGE %]" id = "f_detail" name="f_detail"></frame>
  <noframes>
  <body>
  You do not appear to have a frames capable browser.
  </body>
  </noframes>
  </frameset>

};

}
1;
