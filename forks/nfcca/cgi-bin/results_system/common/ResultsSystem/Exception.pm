package ResultsSystem::Exception;

use strict;
use warnings;

use overload '""' => 'stringify';

=head1 ResultsSystem::Exception

=cut

=head2 new

ResultsSystem::Exception->new( $code, $message, $previous );

=cut

sub new {
  my ( $class, $code, $message, $previous ) = @_;
  my $self = {};
  $self->{code}     = $code;
  $self->{message}  = $message;
  $self->{previous} = $previous;
  return bless $self, $class;
}

=head2 stringify

=cut

sub stringify {
  my ($self) = @_;
  my $line = [ $self->get_code, $self->get_message ];
  push @$line, $self->get_previous if $self->get_previous;

  return join( ",", @$line ) . "\n";
}

=head2 get_code

=cut

sub get_code { my $self = shift; return $self->{code}; }

=head2 get_message

=cut

sub get_message { my $self = shift; return $self->{message}; }

=head2 get_previous

=cut

sub get_previous { my $self = shift; return $self->{previous}; }

1;

