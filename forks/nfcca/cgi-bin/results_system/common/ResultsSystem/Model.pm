package ResultsSystem::Model;

use strict;
use warnings;

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

$self->set_arguments( qw/ logger configuration week_data fixtures / );

=cut

sub set_arguments {
my ($self, @args)=@_;
    my $args=\@args;
    foreach my $a ( @args ) {
      my $m = 'set_' . $a;
      my $k = '-'.$a;
      $self->$m($args->{$k});
    }
return 1;
}

1;
