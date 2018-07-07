
=head1 NAME 

ResultsSystem::Controller::WeekFixtures

=cut

=head1 SYNOPSIS

  my $wf = ResultsSystem::Controller::WeekFixtures->new(
  	   { -configuration => $conf, -logger => $logger } );
  
  $wf->run( $query );

=cut

=head1 DESCRIPTION 

Return an HTML page containing the fixtures for a division and a matchdate.

=cut

package ResultsSystem::Controller::WeekFixtures;

use strict;
use warnings;

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

  $self->{logger} = $args->{-logger} if $args->{-logger};

  $self->{week_fixtures_selector_model} = $args->{-week_fixtures_selector_model}
    if $args->{-week_fixtures_selector_model};
  $self->{configuration} = $args->{-configuration}
    if $args->{-configuration};

  $self->{week_fixtures_view} = $args->{-week_fixtures_view} if $args->{-week_fixtures_view};

  return $self;
}

=head2 run

  $wf->run( $query );

=cut

sub run {
  my ( $self, $query ) = @_;

  my $selector = $self->get_week_fixtures_selector_model;

  my $data->{rows} = $selector->select( { -week => $query->param('matchdate') } );

  $data->{SYSTEM} = $self->get_configuration->get_system;
  $data->{SEASON} = $self->get_configuration->get_season;
  $data->{MENU_NAME} =
    $self->get_configuration->get_name( -csv_file => $query->param('division') )->{menu_name};
  $data->{WEEK}     = $query->param('matchdate');
  $data->{TITLE}    = $self->get_configuration->get_title;
  $data->{DIVISION} = $query->param('division');

  $self->get_week_fixtures_view()->run( { -data => $data } );

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

=head2 get_week_fixtures_view

=cut

sub get_week_fixtures_view {
  my $self = shift;
  return $self->{week_fixtures_view};
}

=head2 get_week_fixtures_selector_model

=cut

sub get_week_fixtures_selector_model {
  my $self = shift;
  return $self->{week_fixtures_selector_model};
}

=head2 get_configuration

=cut

sub get_configuration {
  my $self = shift;
  return $self->{configuration};
}

1;

