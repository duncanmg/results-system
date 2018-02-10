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
use ResultsSystem::Exception;

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

  my $data = {};
  my $wd   = $self->get_week_data;

  $wd->set_division( $args->{-division} );
  $wd->set_week( $args->{-week} );

  $self->set_division( $args->{-division} );
  $self->set_week( $args->{-week} );

  $wd->read_file;

  $data->{SYSTEM} = $self->get_configuration->get_system;
  $data->{SEASON} = $self->get_configuration->get_season;
  $data->{MENU_NAME} =
    $self->get_configuration->get_name( -csv_file => $self->get_division )->{menu_name};
  $data->{WEEK}     = $self->get_week;
  $data->{TITLE}    = $self->get_configuration->get_title;
  $data->{DIVISION} = $self->get_division;

  $data->{rows} = scalar( $wd->get_lines ) ? $wd->get_lines : $self->_get_team_names;

  return $data;
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
  $self->logger->debug("get_team_names() called.");

  my $week = $self->get_fixtures_for_division_and_week;

  my $names = [ map { ( $_->{home}, $_->{away} ) } @$week ];

  $names = [ map { { team => $_ } } @$names ];

  $self->logger->debug( "get_team_names(). " . Dumper($names) );
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
  $self->logger->debug( 'NOW get_fixtures_for_division_and_week ' . ref($fixtures) );
  $fixtures->set_division( $self->get_division );

  my $ff = $self->build_fixtures_full_filename();
  $fixtures->set_full_filename($ff);

  $fixtures->read_file();

  my $fixtures_for_week = $fixtures->get_week_fixtures( -date => $self->get_week );

  $self->logger->debug( 'WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW ' . Dumper($fixtures_for_week) );
  return $fixtures_for_week;
}

=head build_fixtures_full_filename

=cut

sub build_fixtures_full_filename {
  my ($self) = @_;
  my $c      = $self->get_configuration;
  my $season = $c->get_season;
  my $ff = $c->get_path( -csv_files => 'Y' ) . "/" . $season . "/" . $self->get_division;
  die ResultsSystem::Exception->new( 'FILE_DOES_NOT_EXIST', $ff ) if !-f $ff;
  return $ff;
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
  die ResultsSystem::Exception->new( 'MISSING_DEPENDENCY', 'No Fixtures object' )
    if !$self->{FIXTURES};
  return $self->{FIXTURES};
}

=head3 set_division

=cut

sub set_division {
  my ( $self, $v ) = @_;
  $self->{division} = $v;
  return $self;
}

=head3 get_division

=cut

sub get_division {
  my $self = shift;
  return $self->{division};
}

=head3 set_week

=cut

sub set_week {
  my ( $self, $v ) = @_;
  $self->{week} = $v;
  return $self;
}

=head3 get_week

=cut

sub get_week {
  my $self = shift;
  return $self->{week};
}

1;

