package ResultsSystem::Controller::MenuJs;

use strict;
use warnings;

=head1 NAME

ResultsSystem::Controller::MenuJs

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger}        = $args->{-logger}        if $args->{-logger};
  $self->{menu_js_model} = $args->{-menu_js_model} if $args->{-menu_js_model};
  $self->{menu_js_view}  = $args->{-menu_js_view}  if $args->{-menu_js_view};
  $self->{logger}->debug('Created object') if $args->{-logger};
  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $args ) = @_;

  $self->{logger}->debug('In run');
  $self->{logger}->debug( ref $self->get_menu_js_model );
  my $data = $self->get_menu_js_model()->run($args);

  $self->{logger}->debug('2 In run');
  $self->get_menu_js_view()->run( { -data => $data } );

  $self->{logger}->debug('3 In run');
  return 1;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

=head2 get_menu_js_view

=cut

sub get_menu_js_view {
  my $self = shift;
  return $self->{menu_js_view};
}

=head2 get_menu_js_model

=cut

sub get_menu_js_model {
  my $self = shift;
  return $self->{menu_js_model};
}

1;

