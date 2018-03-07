=head1 NAME

ResultsSystem::View::Frame

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::View

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut


package ResultsSystem::View::Frame;

use strict;
use warnings;

use ResultsSystem::View;
use parent qw/ ResultsSystem::View/;

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger} = $args->{-logger} if $args->{-logger};
  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  my $html = $self->get_html;

  $html = $self->merge_content( $html, $data );

  $html = $self->merge_content( $self->html_frame_wrapper,
    { CONTENT => $html, PAGETITLE => 'Results System', STYLESHEETS => "" } );

  $self->render( { -data => $html } );
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

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

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

# TODO print $q->header( -expires => "+2d" );

1;
