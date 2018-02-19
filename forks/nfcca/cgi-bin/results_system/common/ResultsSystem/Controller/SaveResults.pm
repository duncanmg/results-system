package ResultsSystem::Controller::SaveResults;

=head1 ResultsSystem::Controller::SaveResults

=cut

use strict;
use warnings;
use Data::Dumper;

=head2 new

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger}             = $args->{-logger}             if $args->{-logger};
  $self->{save_results_model} = $args->{-save_results_model} if $args->{-save_results_model};
  $self->{pwd_model}          = $args->{-pwd_model}          if $args->{-pwd_model};
  $self->{save_results_view}  = $args->{-save_results_view}  if $args->{-save_results_view};
  $self->{message_view}       = $args->{-message_view}       if $args->{-message_view};
  $self->{league_table_model} = $args->{-league_table_model} if $args->{-league_table_model};
  $self->{league_table_view}  = $args->{-league_table_view}  if $args->{-league_table_view};
  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $query ) = @_;

  my $pwd = $self->get_pwd_model;
  my ( $ok, $msg ) =
    $pwd->check_pwd( -user => $query->param('user'), -code => $query->param('code') );
  if ( !$ok ) {
    $self->logger->warn($msg);
    $self->get_message_view->run( { -data => $msg } );
    return 1;
  }

  eval {
    my $data = $self->get_save_results_model()->run( { -params => { $query->Vars } } );

    $self->logger->debug("About to create league table");
    my $lt = $self->get_league_table_model->set_division( $query->param('division') )
      ->create_league_table;
    $self->logger->debug( Dumper $lt);

    $self->get_league_table_view->run(
      { -data => { rows => $lt, division => $query->param('division') } } );

    $self->get_message_view->run( { -data => "Your changes have been accepted." } );
    1;
  } || do {
    my $err = $@;
    $self->logger->error($err);
    $self->get_message_view->run( { -data => "Your changes have been rejected." } );
  };

  # $self->get_save_results_view()->run( { -data => $data } );
}

=head2 get_save_results_view

=cut

sub get_save_results_view {
  my $self = shift;
  return $self->{save_results_view};
}

=head2 get_save_results_model

=cut

sub get_save_results_model {
  my $self = shift;
  return $self->{save_results_model};
}

=head2 get_pwd_model

=cut

sub get_pwd_model {
  my $self = shift;
  return $self->{pwd_model};
}

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

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

1;

