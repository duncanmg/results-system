
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
  $self->{logger}              = $args->{-logger}              if $args->{-logger};
  $self->{week_fixtures_model} = $args->{-week_fixtures_model} if $args->{-week_fixtures_model};
  $self->{week_fixtures_view}  = $args->{-week_fixtures_view}  if $args->{-week_fixtures_view};
  return $self;
}

=head2 run

  $wf->run( $query );

=cut

sub run {
  my ( $self, $query ) = @_;

  my $data =
    $self->get_week_fixtures_model()
    ->run( { -division => $query->param('division'), -week => $query->param('matchdate') } );

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

=head2 get_week_fixtures_model

=cut

sub get_week_fixtures_model {
  my $self = shift;
  return $self->{week_fixtures_model};
}

1;

