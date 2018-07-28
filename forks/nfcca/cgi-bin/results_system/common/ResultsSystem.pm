
=head1 NAME

ResultsSystem

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

package ResultsSystem;

use strict;
use warnings;

use Params::Validate qw/:all/;
use ResultsSystem::Factory;

=head2 new

The constructor takes no arguments.

=cut

sub new {
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  my $self = {};
  $self->{factory} = ResultsSystem::Factory->new();
  return bless $self, $class;
}

=head2 get_factory

Return a ResultsSystem::Factory object.

=cut

sub get_factory {
  my $self = shift;
  return $self->{factory};
}

=head2 get_starter

Uses the factory to return a ResultsSystem::Starter object.

=cut

sub get_starter {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return $self->get_factory->get_starter($args);

}

=head2 get_router

Uses the factory to return a Results::System::Router objects.

=cut

sub get_router {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF, default => {} } );
  return $self->get_factory->get_router($args);
}

1;
