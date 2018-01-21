package ResultsSystem::View;

use strict;
use warnings;

use CGI;
use HTTP::Response;
use HTTP::Status qw/:constants status_message/;

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger} = $args->{-logger} if $args->{-logger};
  return $self;
}

sub logger {
  my $self = shift;
  return $self->{logger};
}

sub render {
  my ( $self, $args ) = @_;
  my $data = $args->{-data};

  my $q = CGI->new();

  my $response = HTTP::Response->new( HTTP_OK,
    status_message(HTTP_OK),
    [ 'Content-Type' => 'text/html; charset=ISO-8859-1',
      'Status'       => HTTP_OK . " " . status_message(HTTP_OK)
    ],
    $q->start_html . "\n" . $data . "\n" . $q->end_html
  );

  print $response->headers->as_string . "\n\n";
  print $response->content . "\n";

}

1;
