package ResultsSystem::Controller::LeagueTable;

=head1 NAME

ResultsSystem::Controller::LeagueTable

=cut

use strict;
use warnings;
use Data::Dumper;
use HTTP::Status qw(:constants :is status_message);

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

Creates the league table for a division. Must not be called directly. User must
have already been authenticated.

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

  $self->{logger}             = $args->{-logger}             if $args->{-logger};
  $self->{message_view}       = $args->{-message_view}       if $args->{-message_view};
  $self->{league_table_model} = $args->{-league_table_model} if $args->{-league_table_model};
  $self->{league_table_view}  = $args->{-league_table_view}  if $args->{-league_table_view};

  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $query ) = @_;

  $self->logger->debug("About to create league table");
  my $lt =
    $self->get_league_table_model->set_division( $query->param('division') )->create_league_table;
  $self->logger->debug( Dumper $lt);

  $self->get_league_table_view->run(
    { -data => { rows => $lt, division => $query->param('division') } } );

  return 1;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_league_table_model

=cut

sub get_league_table_model {
  my $self = shift;
  return $self->{league_table_model};
}

=head2 get_league_table_view

=cut

sub get_league_table_view {
  my $self = shift;
  return $self->{league_table_view};
}

=head2 get_message_view

=cut

sub get_message_view {
  my $self = shift;
  return $self->{message_view};
}

=head3 logger

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

