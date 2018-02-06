package ResultsSystem::Model;

use strict;
use warnings;
use Params::Validate qw/:all/;

=head1 Menu

=cut

=head2 Methods

=cut

=head3 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

=head3 set_logger

=cut

sub set_logger {
  my $self = shift;
  $self->{logger} = shift;
  return $self;
}

=head3 get_configuration

=cut

sub get_configuration {
  my $self = shift;
  return $self->{configuration};
}

=head3 set_configuration

=cut

sub set_configuration {
  my $self = shift;
  $self->{configuration} = shift;
  return $self;
}

=head3 set_arguments

$self->set_arguments( [ qw/ logger configuration week_data fixtures / ], $args );

=cut

sub set_arguments {
  my ( $self, $map, $args ) = validate_pos( @_, 1, { type => ARRAYREF }, { type => HASHREF } );

  foreach my $m (@$map) {
    my $method = 'set_' . $m;
    my $key    = '-' . $m;
    $self->$method( $args->{$key} );
  }
  return 1;
}

1;
