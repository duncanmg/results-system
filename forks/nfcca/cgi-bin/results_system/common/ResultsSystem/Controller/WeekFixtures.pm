package ResultsSystem::Controller::WeekFixtures;

use strict;
use warnings;

use ResultsSystem::View;
use parent qw/ ResultsSystem::View/;

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger}              = $args->{-logger}              if $args->{-logger};
  $self->{week_fixtures_model} = $args->{-week_fixtures_model} if $args->{-week_fixtures_model};
  $self->{week_fixtures_view}  = $args->{-week_fixtures_view}  if $args->{-week_fixtures_view};
  return $self;
}

sub logger {
  my $self = shift;
  return $self->{logger};
}

sub run {
  my ( $self, $query ) = @_;

  my $data =
    $self->get_week_fixtures_model()
    ->run(
    { -division => $query->param('division'), -matchdate => $query->param('matchdate') }
    );

  $self->get_week_fixtures_view()->run( { -data => $data } );
}

sub get_week_fixtures_view {
  my $self = shift;
  return $self->{week_fixtures_view};
}

sub get_week_fixtures_model {
  my $self = shift;
  return $self->{week_fixtures_model};
}

1;

