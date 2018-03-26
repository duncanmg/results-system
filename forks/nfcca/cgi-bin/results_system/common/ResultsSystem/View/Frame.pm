
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
  $self->set_arguments( [qw/ logger configuration  /], $args );
  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  my $html = $self->get_html;

  $html = $self->merge_content( $html, $data );

  $html = $self->merge_content( $self->html5_wrapper,
    { CONTENT => $html, PAGETITLE => 'Results System' } );

  $html = $self->merge_stylesheets( $html, ["/results_system/custom/nfcca/frame_styles.css"] );

  $self->render( { -data => $html } );
  return 1;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_html

=cut

sub get_html {

  #  my $output = <<'HTML';
  #
  #  <frameset rows="30%,*">
  #  <frame noresize="noresize" src="[% MENU_PAGE %]" id = "f_menu"
  #    name="f_menu" scrolling="auto"></frame>
  #  <frame scrolling="auto" src="[% BLANK_PAGE %]" id = "f_detail" name="f_detail"></frame>
  #  <noframes>
  #  <body>
  #  You do not appear to have a frames capable browser.
  #  </body>
  #  </noframes>
  #  </frameset>
  #
  #HTML

  my $output = <<'HTML';

  <div id="iframe_holder">
    <div id="iframe_holder_menu">
      <iframe src="[% MENU_PAGE %]" id = "f_menu" name="f_menu" ></iframe>
    </div>
    <div id="iframe_holder_detail">
      <iframe src="[% BLANK_PAGE %]" id = "f_detail" name="f_detail" ></iframe>
    </div>
  </div>

HTML
  return $output;
}

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

# TODO print $q->header( -expires => "+2d" );

1;
