package ResultsSystem;

use strict;
use warnings;

use Params::Validate qw/:all/;
use ResultsSystem::Factory;

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};
  $self->{factory} = ResultsSystem::Factory->new();
  return bless $self, $class;
}

sub get_factory {
  my $self = shift;
  return $self->{factory};
}

sub get_starter {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return $self->get_factory->get_starter($args);

}

sub get_router {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return $self->get_factory->get_router($args);
}

1;
