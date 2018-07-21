package ResultsSystem::Controller::SaveResults;

=head1 NAME

ResultsSystem::Controller::SaveResults

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
  $self->{locker} = $args->{-locker} if $args->{-locker};

  $self->{save_results_model} = $args->{-save_results_model} if $args->{-save_results_model};
  $self->{save_results_view}  = $args->{-save_results_view}  if $args->{-save_results_view};

  $self->{message_view} = $args->{-message_view} if $args->{-message_view};

  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $query ) = @_;

  my $locker = $self->get_locker;

  eval {
    $locker->open_lock_file;
    my $data = $self->get_save_results_model()->run( { -params => { $query->Vars } } );

    $self->get_message_view->run( { -data => "Your changes have been accepted." } );
    $locker->close_lock_file;
    1;
  } || do {
    my $err = $@;
    $self->logger->error($err);
    $self->get_message_view->run( { -data => "Your changes have been rejected." } );
    $locker->close_lock_file;
    return;
  };

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

=head2 get_message_view

=cut

sub get_message_view {
  my $self = shift;
  return $self->{message_view};
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

<p><img src="http://www.results_system_nfcca_uml.com/class_diagram_controller_save_results.jpeg"
width="1000" height="500" alt="Line Chart" /></p>

=end HTML

=head2 Activity Diagram

=begin HTML

<p><img src="http://www.results_system_nfcca_uml.com/activity_diagram_controller_save_results.jpeg"
width="1000" height="500" alt="Line Chart" /></p>

=end HTML

=cut

1;

