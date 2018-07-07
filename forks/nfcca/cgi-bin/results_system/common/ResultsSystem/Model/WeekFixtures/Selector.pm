
=head1 NAME

ResultsSystem::Model::WeekFixtures::Selector

=cut

=head1 SYNOPSIS


Usage:

  my $wf = ResultsSystem::Model::WeekFixtures::Selector->new( 
    { -logger => $logger, -configuration => $configuration,  
      -week_results  => $week_results, -fixtures => $fixtures, 
      -fixtures_adapter => $fixtures_adapter});

  $wf->select({ -division => $d, -week => $matchdate,
             -week_results => $wd, -fixtures => $f });

This module returns the results for a given division and date.

If there aren't any results then it uses the fixtures to create
and return a structure containing the team names and with the keys
set to defaults.

=cut

=head1 DESCRIPTION

This modules selects the results for a week. If there aren't any results
then it returns the fixtures for the week.

=cut

=head1 INHERITS FROM

L<ResultsSystem::Model::WeekFixtures|http://www.results_system_nfcca.com:8088/ResultsSystem/Model/WeekFixtures>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::Model::WeekFixtures::Selector;

use strict;
use warnings;
use Carp;

use Data::Dumper;
use ResultsSystem::Exception;
use Params::Validate qw/:all/;

use parent qw/ ResultsSystem::Model::WeekFixtures /;

=head2 new

Constructor.

-logger: Logger object

-configuration: Configuration object

-week_results: WeekResults::Reader object. Will already have loaded the results for the division and matchdate if the are any.

-fixtures: Fixtures object. Will aleady have loaded the fixture for the division for the whole season.

-fixtures_adapter : WeekFixtures::Adapter object

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->set_arguments( [qw/ logger configuration week_results fixtures fixtures_adapter /],
    $args );

  return $self;
}

=head2 select

  my $rows = $wf->select({ -week => $matchdate });

=cut

sub select {
  my $self = shift;
  my (%args) = validate( @_, { -week => 1 } );

  my $rows = {};

  $self->set_week( $args{-week} );

  $rows = $self->_get_results_for_week;

  $rows = $self->_get_adapted_fixtures if !scalar( @{$rows} );

  $self->logger->debug( Dumper $rows);
  return $rows;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _get_results for_week

=cut

sub _get_results_for_week {
  my ($self) = validate_pos( @_, 1 );

  my $wd = $self->get_week_results;

  return $wd->get_lines;
}

=head2 _get_adapted_fixtures

=cut

sub _get_adapted_fixtures {
  my ($self) = validate_pos( @_, 1 );

  my $fixtures = $self->_get_fixtures_for_division_and_week;

  my $adapter = $self->get_fixtures_adapter;

  return $adapter->adapt( { -fixtures => $fixtures } );
}

=head2 _get_fixtures_for_division_and_week

Returns the fixtures for the week as an array ref.

=cut

#***************************************
sub _get_fixtures_for_division_and_week {

  #***************************************
  my $self = shift;

  my $fixtures = $self->get_fixtures;
  $self->logger->debug( 'NOW get_fixtures_for_division_and_week ' . ref($fixtures) );

  my $fixtures_for_week = $fixtures->get_week_fixtures( -date => $self->get_week );

  $self->logger->debug( Dumper($fixtures_for_week) );
  return $fixtures_for_week;
}

=head2 set_week_results

=cut

sub set_week_results {
  my ( $self, $v ) = @_;
  $self->{WEEK_DATA} = $v;
  return $self;
}

=head2 get_week_results

=cut

sub get_week_results {
  my $self = shift;
  return $self->{WEEK_DATA};
}

=head2 set_fixtures

=cut

sub set_fixtures {
  my ( $self, $v ) = @_;
  $self->{FIXTURES} = $v;
  return $self;
}

=head2 get_fixtures

=cut

sub get_fixtures {
  my $self = shift;
  croak( ResultsSystem::Exception->new( 'MISSING_DEPENDENCY', 'No Fixtures object' ) )
    if !$self->{FIXTURES};
  return $self->{FIXTURES};
}

=head2 set_fixtures_adapter

=cut

sub set_fixtures_adapter {
  my ( $self, $v ) = @_;
  $self->{fixtures_adapter} = $v;
  return $self;
}

=head2 get_fixtures_adapter

=cut

sub get_fixtures_adapter {
  my $self = shift;
  return $self->{fixtures_adapter};
}

=head2 get_week

=cut

sub get_week {
  my $self = shift;
  return $self->{week};
}

=head2 set_week

=cut

sub set_week {
  my ( $self, $v ) = validate_pos( @_, 1, 1 );
  $self->{week} = $v;
  return $self;
}

1;

