package ResultsSystem::Controller::Pwd;

=head1 NAME

ResultsSystem::Controller::Pwd

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

  $DB::single = 1;

  $self->{logger}    = $args->{-logger}    if $args->{-logger};
  $self->{pwd_model} = $args->{-pwd_model} if $args->{-pwd_model};
  $self->{message_view} = $args->{-message_view} if $args->{-message_view};

  return $self;
}

=head2 run

Authenticates the user.

On success returns true.

On failure, outputs an error page and returns false to prevent further processing;

=cut

sub run {
  my ( $self, $query ) = @_;

  my $pwd = $self->get_pwd_model;

  my ( $ok, $msg ) =
    $pwd->check_pwd( -user => $query->param('user'), -code => $query->param('code') );
  if ( !$ok ) {
    $self->logger->warn($msg);
    $self->get_message_view->run( { -data => $msg, -status_code => HTTP_UNAUTHORIZED } );
    return;
  }

  return 1;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 get_pwd_model

=cut

sub get_pwd_model {
  my $self = shift;
  return $self->{pwd_model};
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

=head1 UML

=head2 Class Diagram

=head2 Activity Diagram

=cut

1;

