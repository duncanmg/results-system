package ResultsSystem::Controller::SaveResults;

use strict;
use warnings;

use ResultsSystem::View;
use parent qw/ ResultsSystem::View/;

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger}             = $args->{-logger}             if $args->{-logger};
  $self->{save_results_model} = $args->{-save_results_model} if $args->{-save_results_model};
  $self->{save_results_view}  = $args->{-save_results_view}  if $args->{-save_results_view};
  return $self;
}

sub logger {
  my $self = shift;
  return $self->{logger};
}

sub run {
  my ( $self, $query ) = @_;

  my $data = $self->get_save_results_model()->run( { -params => { $query->Vars } } );

  # $self->get_save_results_view()->run( { -data => $data } );
}

sub get_save_results_view {
  my $self = shift;
  return $self->{save_results_view};
}

sub get_save_results_model {
  my $self = shift;
  return $self->{save_results_model};
}

1;

