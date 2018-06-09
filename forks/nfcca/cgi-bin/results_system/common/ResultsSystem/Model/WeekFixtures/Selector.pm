
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

-week_results: WeekResults::Reader object

-fixtures: Fixtures object

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

  my $rows = $wf->select({ -division => $d, -week => $matchdate });

=cut

sub select {
  my $self = shift;
  my (%args) = validate( @_, { -division => 1, -week => 1 } );

  $self->set_division( $args{-division} );
  $self->set_week( $args{-week} );

  my $rows = {};

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

  $wd->set_division( $self->get_division );
  $wd->set_week( $self->get_week );

  $wd->read_file;
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
  $fixtures->set_division( $self->get_division );

  my $ff = $self->_build_fixtures_full_filename();
  $fixtures->set_full_filename($ff);

  $fixtures->read_file();

  my $fixtures_for_week = $fixtures->get_week_fixtures( -date => $self->get_week );

  $self->logger->debug( 'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW ' . Dumper($fixtures_for_week) );
  return $fixtures_for_week;
}

=head2 _build_fixtures_full_filename

=cut

sub _build_fixtures_full_filename {
  my ($self) = @_;
  my $c      = $self->get_configuration;
  my $season = $c->get_season;
  my $ff = $c->get_path( -csv_files => 'Y' ) . "/" . $season . "/" . $self->get_division;
  croak( ResultsSystem::Exception->new( 'FILE_DOES_NOT_EXIST', $ff ) ) if !-f $ff;
  return $ff;
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

=head2 set_division

=cut

sub set_division {
  my ( $self, $v ) = @_;
  $self->{division} = $v;
  return $self;
}

=head2 get_division

=cut

sub get_division {
  my $self = shift;
  return $self->{division};
}

=head2 set_week

=cut

sub set_week {
  my ( $self, $v ) = @_;
  $self->{week} = $v;
  return $self;
}

=head2 get_week

=cut

sub get_week {
  my $self = shift;
  return $self->{week};
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

1;

