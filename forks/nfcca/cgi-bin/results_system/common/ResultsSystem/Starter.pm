package ResultsSystem::Starter;

=head1 NAME

ResultsSystem::Starter

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

use strict;
use warnings;
use Carp;

use Params::Validate qw/:all/;

=head2 new

=cut

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};
  bless $self, $class;
  $self->set_system( $args->{-system} )               if $args->{-system};
  $self->set_configuration( $args->{-configuration} ) if $args->{-configuration};
  return $self;
}

=head2 start

=cut

sub start {
  my ( $self, $system, $division, $matchdate ) = validate_pos( @_, 1, 0, 0, 0 );

  $self->set_system($system) if $system;
  croak( ResultsSystem::Exception->new( 'NO_SYSTEM', 'System is not set.' ) )
    if !$self->get_system;

  my $conf = $self->get_configuration;
  $conf->set_system($system);

  # read_file returns false on success.
  $conf->read_file
    && croak( ResultsSystem::Exception->new( 'NO_SYSTEM', 'Unable to read system file.' ) );

  $conf->set_csv_file($division)   if $division;
  $conf->set_matchdate($matchdate) if $matchdate;
  return $self;
}

=head2 set_system

=cut

sub set_system {
  my ( $self, $system ) = @_;
  $self->{system} = $system;
  return $self->{system};
}

=head2 get_system

=cut

sub get_system {
  my $self = shift;
  return $self->{system};
}

=head2 set_configuration

=cut

sub set_configuration {
  my ( $self, $conf ) = @_;
  $self->{configuration} = $conf;
  return $self->{configuration};
}

=head2 get_configuration

=cut

sub get_configuration {
  my ($self) = @_;
  return $self->{configuration};
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

1;
