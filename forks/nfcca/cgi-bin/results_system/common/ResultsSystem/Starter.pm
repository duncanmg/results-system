package ResultsSystem::Starter;

use strict;
use warnings;

use Params::Validate qw/:all/;

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};
  bless $self, $class;
  $self->set_system( $args->{-system} )               if $args->{-system};
  $self->set_configuration( $args->{-configuration} ) if $args->{-configuration};
  return $self;
}

sub start {
  my ( $self, $system ) = validate_pos( @_, 1, 0 );

  $self->set_system($system) if $system;
  croak ResultsSystem::Exception->new( 'NO_SYSYEM', 'System is not set.' ) if !$self->get_system;

  my $conf = $self->get_configuration;
  $conf->set_system($system);
  $conf->read_file;

}

sub set_system {
  my ( $self, $system ) = @_;
  $self->{system} = $system;
  return $self->{system};
}

sub get_system {
  my $self = shift;
  return $self->{system};
}

sub set_configuration {
  my ( $self, $conf ) = @_;
  $self->{configuration} = $conf;
  return $self->{configuration};
}

sub get_configuration {
  my ($self) = @_;
  return $self->{configuration};
}

1;
