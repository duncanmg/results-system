package ResultsSystem::Controller::WeekResults;

=head1 NAME

ResultsSystem::Controller::WeekResults

=cut

use strict;
use warnings;
use Data::Dumper;
use HTTP::Status qw(:constants :is status_message);

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

  $self->{logger} = $args->{-logger} if $args->{-logger};

  $self->{week_results_reader_model} = $args->{-week_results_reader_model}
    if $args->{-week_results_reader_model};

  $self->{week_results_view} = $args->{-week_results_view} if $args->{-week_results_view};

  $self->logger->warn('Created');
  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $query ) = @_;

  $self->logger->warn('1');
  my $data = $self->get_week_results_reader_model()->get_lines();

  $self->logger->warn('2');
  $self->get_week_results_view->run(
    { -data => {
        rows     => $data,
        division => $query->param('division'),
        week     => $query->param('matchdate')
      }
    }
  );

  $self->logger->warn('3');
  return 1;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_save_results_model

=cut

sub get_save_results_model {
  my $self = shift;
  return $self->{save_results_model};
}

=head2 get_week_results_reader_model

=cut

sub get_week_results_reader_model {
  my $self = shift;
  return $self->{week_results_reader_model};
}

=head2 get_week_results_view

=cut

sub get_week_results_view {
  my $self = shift;
  return $self->{week_results_view};
}

=head2 get_locker

=cut

sub get_locker {
  my $self = shift;
  return $self->{locker};
}

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

=head1 UML

=head2 Class Diagram

=begin HTML

<p><img src="http://www.results_system_nfcca_uml.com/class_diagram_controller_week_results.jpeg"
width="1000" height="500" alt="Line Chart" /></p>

=end HTML

=head2 Activity Diagram

=begin HTML

<p><img src="http://www.results_system_nfcca_uml.com/activity_diagram_controller_week_results.jpeg"
width="1000" height="500" alt="Line Chart" /></p>

=end HTML

=cut

1;

