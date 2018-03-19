
=head1 NAME

ResultsSystem::Model::WeekFixtures

=cut

=head1 SYNOPSIS


Usage:

  my $wf = ResultsSystem::Model::WeekFixtures->new( 
    { -logger => $logger, -configuration => -configuration });

  $wf->run({-full_filename => $ff, -division => $d, -week => $matchdate });

  This module returns the results for a given division and date.

  If there aren't any results then it uses the fixtures to create
  and return a structure containing the team names and with the keys
  set to defaults.

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::Model

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::Model::WeekFixtures;

use strict;
use warnings;
use Carp;

use Data::Dumper;
use ResultsSystem::Exception;
use Params::Validate qw/:all/;

use parent qw/ ResultsSystem::Model /;

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

=head2 run

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

  if ( scalar( $wd->get_lines ) ) {
    $data->{rows} = $wd->get_lines;
  }
  else {
    my $team_names = $self->_get_team_names;
    $data->{rows} = $self->reformat_team_names($team_names);
  }

  $self->logger->debug( Dumper $data);
  return $data;
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
  my $self = shift;

  my $week = $self->get_fixtures_for_division_and_week;

  my $names = [ map { ( $_->{home}, $_->{away} ) } @$week ];

  $names = [ map { { team => $_ } } @$names ];

  return $names;

}

=head2 reformat_team_names

=cut

sub reformat_team_names {
  my ( $self, $team_names ) = validate_pos( @_, 1, { type => ARRAYREF } );
  my @labels = $self->get_week_data->get_labels;
  my $out    = [];
  foreach my $t (@$team_names) {
    my $hr = {};
    foreach my $l (@labels) {
      if ( !exists( $t->{$l} ) ) {
        if ( $l =~ m/^(team|performances|played|result)$/x ) {
          $hr->{$l} = ""  if ( $l =~ m/^(team|performances)$/x );
          $hr->{$l} = 'N' if $l eq 'played';
          $hr->{$l} = 'W' if $l eq 'result';
        }
        else {
          $hr->{$l} = 0;
        }
      }
      else {
        $hr->{$l} = $t->{$l};
      }
    }
    push @$out, $hr;
  }
  return $out;
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

=head2 build_fixtures_full_filename

=cut

sub build_fixtures_full_filename {
  my ($self) = @_;
  my $c      = $self->get_configuration;
  my $season = $c->get_season;
  my $ff = $c->get_path( -csv_files => 'Y' ) . "/" . $season . "/" . $self->get_division;
  croak ResultsSystem::Exception->new( 'FILE_DOES_NOT_EXIST', $ff ) if !-f $ff;
  return $ff;
}

=head2 set_week_data

=cut

sub set_week_data {
  my ( $self, $v ) = @_;
  $self->{WEEK_DATA} = $v;
  return $self;
}

=head2 get_week_data

=cut

sub get_week_data {
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
  croak ResultsSystem::Exception->new( 'MISSING_DEPENDENCY', 'No Fixtures object' )
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

1;

