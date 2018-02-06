package ResultsSystem::Controller::MenuJs;

use strict;
use warnings;

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger}        = $args->{-logger}        if $args->{-logger};
  $self->{menu_js_model} = $args->{-menu_js_model} if $args->{-menu_js_model};
  $self->{menu_js_view}  = $args->{-menu_js_view}  if $args->{-menu_js_view};
  return $self;
}

sub logger {
  my $self = shift;
  return $self->{logger};
}

sub run {
  my ( $self, $args ) = @_;

  my $data = $self->get_menu_js_model()->run($args);

  $self->get_menu_js_view()->run( { -data => $data } );
}

sub get_menu_js_view {
  my $self = shift;
  return $self->{menu_js_view};
}

sub get_menu_js_model {
  my $self = shift;
  return $self->{menu_js_model};
}

1;

