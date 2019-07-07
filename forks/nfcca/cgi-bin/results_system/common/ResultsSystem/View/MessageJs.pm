
=head1 NAME

ResultsSystem::View::MessageJs

=cut

=head1 SYNOPSIS

  $js->run(
    { -data        => "alert('Help');",
      -status_code => 'HTTP_OK'
    }
  );

Outputs

  Content-Type: text/javascript; charset=ISO-8859-1
  Status: 200 OK
  
  
  alert('Help');

=cut

=head1 DESCRIPTION

Simple view to accept a single string of Javascript and an optional HTTP status code.
Outputs the response.

=cut

=head1 INHERITS FROM

ResultsSystem::View

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::View::MessageJs;

use strict;
use warnings;

use ResultsSystem::View;
use parent qw/ ResultsSystem::View/;

use JSON::Tiny qw(decode_json encode_json);

=head2 new

  my $js = ResultsSystem::View::MessageJs->new({ -logger => $logger });

=cut

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger} = $args->{-logger} if $args->{-logger};
  return $self;
}

=head2 run

  $self->run( { -data => 'Help', -status_code => 'HTTP_OK' } );

=cut

sub run {
  my ( $self, $args ) = @_;

  $self->render_javascript($args);
  return 1;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

1;

