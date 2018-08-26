package ResultsSystem::Controller::WeekResults;

=head1 NAME

ResultsSystem::Controller::WeekResults

=cut

use strict;
use warnings;
use Data::Dumper;
use HTTP::Status qw(:constants :is status_message);

use parent 'ResultsSystem::Controller';

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->set_arguments(
    [qw/ logger configuration week_results_reader_model week_results_view store_divisions_model/],
    $args
  );

  $self->logger->warn('Created');
  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $query ) = @_;

  my $data = $self->get_week_results_reader_model()->get_lines();

  $self->get_week_results_view->run(
    { -data => {
        rows     => $data,
        division => $query->param('division'),
        week     => $query->param('matchdate'),
        MENU_NAME =>
          $self->get_store_divisions_model->get_name( -csv_file => $query->param('division') )
          ->{menu_name},
        SYSTEM => $self->get_configuration->get_system,
      }
    }
  );

  $self->logger->warn('3');
  return 1;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_store_divisions_model

=cut

sub get_store_divisions_model {
  my $self = shift;
  return $self->{store_divisions_model};
}

=head2 set_store_divisions_model

=cut

sub set_store_divisions_model {
  my ( $self, $v ) = @_;
  $self->{store_divisions_model} = $v;
  return $self;
}

=head2 get_week_results_reader_model

=cut

sub get_week_results_reader_model {
  my $self = shift;
  return $self->{week_results_reader_model};
}

=head2 set_week_results_reader_model

=cut

sub set_week_results_reader_model {
  my ( $self, $v ) = @_;
  $self->{week_results_reader_model} = $v;
  return $self;
}

=head2 get_week_results_view

=cut

sub get_week_results_view {
  my $self = shift;
  return $self->{week_results_view};
}

=head2 set_week_results_view

=cut

sub set_week_results_view {
  my ( $self, $v ) = @_;
  $self->{week_results_view} = $v;
  return $self;
}

=head1 UML

=head2 Class Diagram

=begin HTML

<p><img src="http://www.results_system_nfcca_uml.com/class_diagram_controller_week_results.jpeg"
width="1000" height="500" alt="UML" /></p>

=end HTML

=head2 Activity Diagram

=begin HTML

<p><img src="http://www.results_system_nfcca_uml.com/activity_diagram_controller_week_results.jpeg"
width="1000" height="500" alt="UML" /></p>

=end HTML

=cut

1;

