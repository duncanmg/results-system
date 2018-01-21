package ResultsSystem::Exception;

use strict;
use warnings;

use overload '""' => 'stringify';

sub new {
  my ( $class, $code, $message, $previous ) = @_;
  my $self = {};
  $self->{code}     = $code;
  $self->{message}  = $message;
  $self->{previous} = $previous;
  return bless $self, $class;
}

sub stringify {
  my ($self) = @_;
  my $line = [ $self->get_code, $self->get_message ];
  push @$line, $self->get_previous if $self->get_previous;

  return join( ",", @$line );
}

sub get_code { my $self = shift; return $self->{code}; }

sub get_message { my $self = shift; return $self->{message}; }

sub get_previous { my $self = shift; return $self->{previous}; }

1;

