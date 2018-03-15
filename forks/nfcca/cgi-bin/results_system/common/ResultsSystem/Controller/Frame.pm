package ResultsSystem::Controller::Frame;

use strict;
use warnings;

=head1 NAME

ResultsSystem::Controller::Frame

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
  $self->{logger}      = $args->{logger} if $args->{logger};
  $self->{frame_model} = $args->{-frame_model};
  $self->{frame_view}  = $args->{-frame_view};
  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $args ) = @_;

  my $data = $self->get_frame_model->run();

  $self->get_frame_view->run( { -data => $data } );
  return 1;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_frame_model

=cut

sub get_frame_model {
  my $self = shift;
  return $self->{frame_model};
}

=head2 get_frame_view

=cut

sub get_frame_view {
  my $self = shift;
  return $self->{frame_view};
}

1;
