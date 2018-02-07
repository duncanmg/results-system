# ******************************************************
#
# Name: WeekFixtures.pm
#
# 0.1  - 27 Jun 08 - POD added.
#
# ******************************************************

=head1 WeekFixtures.pm

Usage:

  my $wf = ResultsSystem::Model::WeekFixtures->new( 
    { -logger => $logger, -configuration => -configuration });

  $wf->run({-full_filename => $ff, -division => $d, -week => $matchdate });

=cut

package ResultsSystem::Model::WeekFixtures;

use strict;
use warnings;

use Data::Dumper;

use parent qw/ ResultsSystem::Model /;

=head1 Public Methods

=cut

=head2 new

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->set_arguments( [qw/ logger configuration week_data fixtures /], $args );

  $self->logger->debug("WeekFixtures object created.");

  return $self;
}

=head1 run

=cut

sub run {
  my ( $self, $args ) = @_;

  my $wd = $self->get_week_data;

  $wd->set_full_filename($args->{-full_filename});

  $self->set_division($args->{-division});
  $self->set_week($args->{-week});
  
  $wd->read_file;

  return $wd->get_lines if scalar $wd->get_lines;

  return @{ $self->_get_team_names };
}

=head1 Private Methods

=cut

=head2 _get_team_names

This function is called when there aren't any results for the division/week. It
accesses the fixture list and returns the team name from there.

=cut

#***************************************
sub _get_team_names {

  #***************************************
  my $self = shift;
  $self->logger->debug("get_team_name() called.");

  my $week = $self->get_fixtures_for_division_and_week;

  my $names = [ map { ( $_->{home}, $_->{away} ) } @$week ];

  return $names;

}

=head2 get_fixtures_for_division_and_week

Returns the fixtures for the week as an array ref.

=cut

#***************************************
sub get_fixtures_for_division_and_week {

  #***************************************
  my $self = shift;

  my $fixtures = $self->get_fixtures;
  $fixtures->set_division( $self->get_division );

  my $c      = $self->get_configuration;
  my $season = $c->get_season;
  my $ff     = $c->get_path( -csv_files => 'Y' ) . "/" . $season . "/" . $self->get_division;
  $fixtures->set_full_filename($ff);
  my $fixtures_for_week = $fixtures->get_week_fixtures( -date => $self->get_week );

  return $fixtures_for_week;
}

=head3 set_week_data

=cut

sub set_week_data {
  my ( $self, $v ) = @_;
  $self->{WEEK_DATA} = $v;
  return $self;
}

=head3 get_week_data

=cut

sub get_week_data {
  my $self = shift;
  return $self->{WEEK_DATA};
}

=head3 set_fixtures

=cut

sub set_fixtures {
  my ( $self, $v ) = @_;
  $self->{FIXTURES} = $v;
  return $self;
}

=head3 get_fixtures

=cut

sub get_fixtures {
  my $self = shift;
  return $self->{FIXTURES};
}

1;

