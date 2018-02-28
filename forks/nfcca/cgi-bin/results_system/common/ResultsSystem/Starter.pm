package ResultsSystem::Starter;

=head1 ResultsSystem::Starter

=cut

use strict;
use warnings;

use Params::Validate qw/:all/;

=head1 Methods

=cut

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
  my ( $self, $system ) = validate_pos( @_, 1, 0 );

  $self->set_system($system) if $system;
  croak ResultsSystem::Exception->new( 'NO_SYSYEM', 'System is not set.' ) if !$self->get_system;

  my $conf = $self->get_configuration;
  $conf->set_system($system);
  $conf->read_file;
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

1;
