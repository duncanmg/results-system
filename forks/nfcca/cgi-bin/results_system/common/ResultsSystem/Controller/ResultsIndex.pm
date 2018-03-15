package ResultsSystem::Controller::ResultsIndex;

=head1 NAME

ResultsSystem::Controller::ResultsIndex

=cut

use strict;
use warnings;

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

  $self->{logger}              = $args->{-logger}              if $args->{-logger};
  $self->{results_index_model} = $args->{-results_index_model} if $args->{-results_index_model};
  $self->{results_index_view}  = $args->{-results_index_view}  if $args->{-results_index_view};

  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $query ) = @_;

  my $data = $self->get_results_index_model()->run();

  $self->get_results_index_view()->run( { -data => $data } );
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

=head2 get_results_index_model

=cut

sub get_results_index_model {
  my $self = shift;
  return $self->{results_index_model};
}

=head2 get_results_index_view

=cut

sub get_results_index_view {
  my $self = shift;
  return $self->{results_index_view};
}

1;

