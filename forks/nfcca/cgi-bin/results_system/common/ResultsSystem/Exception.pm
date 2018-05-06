package ResultsSystem::Exception;

use strict;
use warnings;

use overload '""' => 'stringify';

=head1 NAME

ResultsSystem::Exception

=cut

=head1 SYNOPSIS

Simple exception object which can accept an error code and a message. It can 
optionally accept another exception object if it is re-throwing a previous 
exception.

  croak( ResultsSystem::Exception->new( 'DIVISION_NOT_SET', 
    'The division has not been set.' ) );

=cut

=head1 DESCRIPTION

Allow exceptions to be handled consistently. Note that the
code is not necessarily an HTTP status code.

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

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

This Exception object, ResultsSystem::Exception->new( 'NO_SYSTEM', 'System is not set.' ),
stringifies to 'NO_SYSTEM,System is not set.' . "\n"

This Exception object, ResultsSystem::Exception->new( 'MIDDLE', 'Middle exception', 
ResultsSystem::Exception->new( 'NO_SYSTEM', 'System is not set.' )), stringifies to
"MIDDLE,Middle exception,NO_SYSTEM,System is not set.\n"

=cut

sub stringify {
  my ($self) = @_;
  my $line = [ $self->get_code, $self->get_message ];
  push @$line, $self->get_previous if $self->get_previous;

  my $str = join( ",", @$line );
  $str .= "\n" if !$self->get_previous;
  return $str;
}

=head2 get_code

Return the code eg 'NO_SYSTEM'.

=cut

sub get_code { my $self = shift; return $self->{code} || ""; }

=head2 get_message

Return the message 'System is not set.'.

=cut

sub get_message { my $self = shift; return $self->{message} || ""; }

=head2 get_previous

Return the previous Exception object of undefined.

=cut

sub get_previous { my $self = shift; return $self->{previous}; }

=head1 INTERNAL (PRIVATE) METHODS

=cut

1;

