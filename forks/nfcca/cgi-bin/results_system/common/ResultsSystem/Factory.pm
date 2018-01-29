package ResultsSystem::Factory;

use strict;
use warnings;
use Params::Validate qw/:all/;

use ResultsSystem::Logger;
use ResultsSystem::Starter;
use ResultsSystem::Router;

use ResultsSystem::Configuration;

use ResultsSystem::Controller::Frame;
use ResultsSystem::Controller::Menu;
use ResultsSystem::Controller::Blank;

use ResultsSystem::Model::Frame;
use ResultsSystem::Model::Menu;
use ResultsSystem::Model::Fixtures;

use ResultsSystem::View::Frame;
use ResultsSystem::View::Menu;
use ResultsSystem::View::Blank;

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};
  $self->set_system( $args->{system} ) if $args->{system};
  return bless $self, $class;
}

sub get_logger {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return ResultsSystem::Logger->new(%$args);
}

sub get_starter {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return ResultsSystem::Starter->new( { -configuration => $self->get_configuration(), %$args } );
}

sub get_router {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return ResultsSystem::Router->new( { -factory => $self, %$args } );
}

sub get_configuration {
  my ( $self, $args ) = @_;
  my $s = sub {

    return ResultsSystem::Configuration->new(
      -logger        => $self->get_logger->screen_logger,
      -full_filename => $args->{-full_filename}
    );
  };
  return $self->lazy( 'configuration', $s );
}

sub lazy {
  my ( $self, $key, $sub ) = validate_pos( @_, 1, 1, 1 );
  if ( !$self->{$key} ) {
    $self->{$key} = $sub->();
  }
  return $self->{$key};
}

sub set_system {
  my $self = shift;
  $self->{SYSTEM} = shift;
  return $self->{SYSTEM};
}

sub get_system {
  my $self = shift;
  return $self->{SYSTEM};
}

sub get_full_filename {
  my $self   = shift;
  my $system = $self->get_system;
  return $system ? "../custom/$system/$system.ini" : undef;
}

=head2 Controllers

=cut

=head3 get_frame_controller

=cut

sub get_frame_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::Frame->new(
    { -logger      => $self->get_logger()->logger,
      -frame_model => $self->get_frame_model,
      -frame_view  => $self->get_frame_view
    }
  );
}

=head3 get_menu_controller

=cut

sub get_menu_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::Menu->new(
    { -logger     => $self->get_logger()->logger,
      -menu_model => $self->get_menu_model,
      -menu_view  => $self->get_menu_view
    }
  );
}

=head3 get_blank_controller

=cut

sub get_blank_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::Blank->new(
    { -logger     => $self->get_logger()->logger,
      -blank_view  => $self->get_blank_view
    }
  );
}

=head2 Models

=cut

=head3 get_frame_model

=cut

sub get_frame_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::Frame->new(
    { -logger        => $self->get_logger()->logger,
      -configuration => $self->get_configuration
    }
  );
}

=head3 get_menu_model

=cut

sub get_menu_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::Menu->new(
    { -logger        => $self->get_logger()->logger,
      -configuration => $self->get_configuration
    }
  );
}

=head3 get_fixtures_model

=cut

sub get_fixtures_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::Fixtures->new(
    { -logger        => $self->get_logger()->logger,
      -configuration => $self->get_configuration
    }
  );
}

=head2 Views

=cut

=head3 get_frame_view

=cut

sub get_frame_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Frame->new( { -logger => $self->get_logger()->logger } );
}

=head3 get_menu_view

=cut

sub get_menu_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Menu->new( { -logger => $self->get_logger()->logger } );
}

=head3 get_blank_view

=cut

sub get_blank_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Blank->new( { -logger => $self->get_logger()->logger } );
}

1;
