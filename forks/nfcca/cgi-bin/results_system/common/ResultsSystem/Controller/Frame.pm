package ResultsSystem::Controller::Frame;

use strict;
use warnings;

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger}      = $args->{logger} if $args->{logger};
  $self->{frame_model} = $args->{-frame_model};
  $self->{frame_view}  = $args->{-frame_view};
  return $self;
}

sub run {
  my ( $self, $args ) = @_;

  my $data = $self->get_frame_model->run();

  $self->get_frame_view->run( { -data => $data } );

}

sub get_frame_model {
  my $self = shift;
  return $self->{frame_model};
}

sub get_frame_view {
  my $self = shift;
  return $self->{frame_view};
}

1;
