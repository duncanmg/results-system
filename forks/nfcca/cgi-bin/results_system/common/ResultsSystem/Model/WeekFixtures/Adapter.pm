
=head1 NAME

ResultsSystem::Model::WeekFixtures::Adapter

=cut

=head1 SYNOPSIS


Usage:

  my $adapter = ResultsSystem::Model::WeekFixtures::Adapter->new( 
    { -logger => $logger, 
      -configuration => $configuration, 
      -week_results => $wr });

  my $results = $adapter->adapt({ -fixtures => $f });

This module adaps a set of fixtures for a week to make them look
like results.

=cut

=head1 DESCRIPTION

This adapts a hash of fixtures for a week and adds the neccessary keys and defaults
to make it look like a hash of results for the week.

=cut

=head1 INHERITS FROM

L<ResultsSystem::Model|http://www.results_system_nfcca.com:8088/ResultsSystem/Model/WeekFixtures>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::Model::WeekFixtures::Adapter;

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

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->set_arguments( [qw/ logger configuration week_results /], $args );

  $self->logger->debug("WeekFixtures::Adapter object created.");

  return $self;
}

=head2 adapt

  my $data = $adapter->adapt({ -fixtures => $f });

=cut

sub adapt {
  my ( $self, $args ) = @_;

  my $fixtures = $args->{-fixtures};

  my $team_names = $self->_get_team_names($fixtures);

  my $wd = [];

  foreach my $t (@$team_names) {
    my $result = $self->get_week_results->get_default_result;
    my $e      = {};
    foreach my $r (@$result) {
      $e->{ $r->{name} } = $r->{value};
    }
    $e->{team} = $t;
    push @$wd, $e;
  }

  return $wd;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _get_team_names

This function is called when there aren't any results for the division/week. It
accesses the fixture list and returns the team name from there.

=cut

#***************************************
sub _get_team_names {

  #***************************************
  my ( $self, $fixtures ) = @_;

  my $names = [ map { ( $_->{home}, $_->{away} ) } @$fixtures ];

  $names = [ map { { team => $_ } } @$names ];

  return $names;

}

=head2 set_week_results

=cut

sub set_week_results {
  my ( $self, $v ) = @_;
  $self->{WEEK_RESULTS} = $v;
  return $self;
}

=head2 get_week_results

=cut

sub get_week_results {
  my $self = shift;
  return $self->{WEEK_RESULTS};
}

1;

