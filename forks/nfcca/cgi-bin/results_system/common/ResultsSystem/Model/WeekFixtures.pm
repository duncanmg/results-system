# ******************************************************
#
# Name: WeekFixtures.pm
#
# 0.1  - 27 Jun 08 - POD added.
#
# ******************************************************

=head1 WeekFixtures.pm

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
    my ($class, $args)=@_;
    my $self = {};
    bless $self, $class;

    $self->set_arguments(qw/ logger configuration week_data fixtures /);

    $self->logger->debug("WeekFixtures object created.");

    return $self;
  }

=head1 Private Methods

=cut

=head2 _get_value_string

This attempts to retrieve the value from the WeekFixtures object. If no data has been saved
for the current week then it returns undefined for all fields except the team name, which is
retrieved from the fixture list.

 Called with 3 parameters: type, lineno and field.
 e.g. $w->get_value_string( "home", 0, "team" );
 
 Returns a string of the form "xxxxxxxxxxxx".
 Returns undef if the value is not found.

=cut

  #***************************************
  sub _get_value_string {

    #***************************************
    my $self = shift;
    my $t    = shift;
    my $l    = shift;
    my $f    = shift;
    my $obj  = $self->_get_week_data;
    my $v;

    $self->logger->debug("get_value_string called() $t $l $f");
    if ($obj) {

      $v = $obj->get_field(
        -type   => "match",
        -lineno => $l,
        -field  => $f,
        -team   => $t
      );
    }

    if ( ( $obj->file_not_found ) && ( $f eq "team" ) ) {
      $v = $self->_get_team_name( -type => "match", -lineno => $l, -team => $t );
    }

    if ($v) {
      $self->logger->debug("Leaving get_value_string(): $v");
      return $v;
    }

  }

=head2 _get_team_name

This function is called when there aren't any results for the division/week. It
accesses the fixture list and returns the team name from there.

 -team    : home or away
 -lineno  : The number of the fixture in the list. Zero based.
 -type    : match 

=cut

  #***************************************
  sub _get_team_name {

    #***************************************
    my $self = shift;
    my %args = (@_);
    my $n;
    $self->logger->debug("get_team_name() called.");

    my $week = $self->get_fixtures_for_division_and_week;

    return if $args{-type} ne "match";

    my $i = $args{-lineno};
    return if ! $i;

    return ( $args{-team} eq "away" ) ? $week->[$i]->{away} : $week->[$i]->{home};
  }

=head2 get_fixtures_for_division_and_week

Returns the fixtures for the week as an array ref.

=cut

  #***************************************
  sub get_fixtures_for_division_and_week {

    #***************************************
    my $self = shift;

    my $fixtures = $self->get_fixtures;
    $fixtures->set_division($self->get_division);

      my $c=$self->get_configuration;
      my $season = $c->get_season;
      my $ff = $c->get_path( -csv_files => 'Y' ) . "/" . $season . "/" . $d;
    $fixtures->set_full_filename($ff);
    my $fixtures_for_week= $fixtures->get_week_fixtures( -date => $self->get_week );

    return $fixtures_for_week;
  }

=head3 set_week_data

=cut

sub set_week_data {
  my ($self,$v)=@_;
  $self->{WEEK_DATA}=$v;
  return $self;
}

=head3 get_week_data

=cut

sub get_week_data {
  my $self=shift;
  return $self->{WEEK_DATA};
}

=head3 set_fixtures

=cut

sub set_fixtures {
  my ($self,$v)=@_;
  $self->{FIXTURES}=$v;
  return $self;
}

=head3 get_fixtures

=cut

sub get_fixtures {
  my $self=shift;
  return $self->{FIXTURES};
}

  1;

