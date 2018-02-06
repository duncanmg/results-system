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
use ResultsSystem::Controller::MenuJs;
use ResultsSystem::Controller::WeekFixtures;

use ResultsSystem::Model::Frame;
use ResultsSystem::Model::Menu;
use ResultsSystem::Model::Fixtures;
use ResultsSystem::Model::MenuJs;
use ResultsSystem::Model::WeekData;
use ResultsSystem::Model::WeekFixtures;
use ResultsSystem::Model::Pwd;

use ResultsSystem::View::Frame;
use ResultsSystem::View::Menu;
use ResultsSystem::View::Blank;
use ResultsSystem::View::MenuJs;
use ResultsSystem::View::WeekFixtures;

=head2 new

=cut

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};
  $self->set_system( $args->{system} ) if $args->{system};
  return bless $self, $class;
}

=head2 Logger

=cut

=head3 get_logger

=cut

sub get_logger {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return ResultsSystem::Logger->new(%$args);
}

=head3 get_screen_logger

=cut

sub get_screen_logger {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return $self->get_logger($args)->screen_logger();
}

=head3 get_file_logger

=cut

sub get_file_logger {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  if ( !( $args->{-log_dir} && $args->{-logfile_stem} ) ) {
    my $c = $self->get_configuration;
    $args->{-log_dir} = $c->get_path( -log_dir => 1 );
    $args->{-logfile_stem} = $c->get_log_stem;
  }
  return $self->get_logger($args)->logger();
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
    { -logger      => $self->get_file_logger(),
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
    { -logger     => $self->get_file_logger(),
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
    { -logger     => $self->get_file_logger(),
      -blank_view => $self->get_blank_view
    }
  );
}

=head3 get_menu_js_controller

=cut

sub get_menu_js_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::MenuJs->new(
    { -logger        => $self->get_file_logger(),
      -menu_js_view  => $self->get_menu_js_view,
      -menu_js_model => $self->get_menu_js_model
    }
  );
}

=head3 get_week_fixtures_controller

=cut

sub get_week_fixtures_controller {
  my ( $self, $args ) = @_;
  return ResultsSystem::Controller::WeekFixtures->new(
    { -logger              => $self->get_file_logger(),
      -week_fixtures_view  => $self->get_week_fixtures_view,
      -week_fixtures_model => $self->get_week_fixtures_model
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
    { -logger        => $self->get_file_logger(),
      -configuration => $self->get_configuration
    }
  );
}

=head3 get_menu_model

=cut

sub get_menu_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::Menu->new(
    { -logger        => $self->get_file_logger(),
      -configuration => $self->get_configuration
    }
  );
}

=head3 get_fixtures_model

=cut

sub get_fixtures_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::Fixtures->new(
    { -logger        => $self->get_file_logger(),
      -configuration => $self->get_configuration
    }
  );
}

=head3 get_menu_js_model

=cut

sub get_menu_js_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::MenuJs->new(
    { -logger        => $self->get_file_logger(),
      -configuration => $self->get_configuration,
      -fixtures      => $self->get_fixtures_model,
    }
  );
}

=head3 get_week_data_model

=cut

sub get_week_data_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::WeekData->new(
    { -logger        => $self->get_file_logger(),
      -configuration => $self->get_configuration,
    }
  );
}

=head3 get_week_fixtures_model

=cut

sub get_week_fixtures_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::WeekFixtures->new(
    { -logger        => $self->get_file_logger(),
      -configuration => $self->get_configuration,
      -week_data     => $self->get_week_data_model,
    }
  );
}

=head3 get_pwd_model

=cut

sub get_pwd_model {
  my ( $self, $args ) = @_;
  return ResultsSystem::Model::Pwd->new(
    { -logger        => $self->get_file_logger(),
      -configuration => $self->get_configuration,
    }
  );
}

=head2 Views

=cut

=head3 get_frame_view

=cut

sub get_frame_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Frame->new( { -logger => $self->get_file_logger() } );
}

=head3 get_menu_view

=cut

sub get_menu_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Menu->new( { -logger => $self->get_file_logger() } );
}

=head3 get_blank_view

=cut

sub get_blank_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::Blank->new( { -logger => $self->get_file_logger() } );
}

=head3 get_menu_js_view

=cut

sub get_menu_js_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::MenuJs->new( { -logger => $self->get_file_logger() } );
}

=head3 get_week_fixtures_view

=cut

sub get_week_fixtures_view {
  my ( $self, $args ) = @_;
  return ResultsSystem::View::WeekFixtures->new( { -logger => $self->get_file_logger() } );
}

1;
