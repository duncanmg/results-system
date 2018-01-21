#! /usr/bin/perl

=head1 Name

results_system.pl

=cut

BEGIN {
  use LoadEnv;
  LoadEnv::run();
}

use strict;
use warnings;

use CGI;
use Params::Validate qw/:all/;
use Data::Dumper;
use HTTP::Response;
use HTTP::Status qw/:constants status_message/;

use ResultsSystem;

my $logger;

=head2 main

=cut

# ******************************************************
sub main {

  # ******************************************************

  my $q;
  eval {
    $q = CGI->new();

    my $rs = ResultsSystem->new();

    $rs->get_starter->start( $q->param('system') );

    $rs->get_router->route($q);

    1;
  } || do {
    my $err = $@;
    print STDERR $err;

    my $response = HTTP::Response->new( HTTP_OK,
      status_message(HTTP_OK),
      [ 'Content-Type' => 'text/html; charset=ISO-8859-1',
        'Status' => HTTP_INTERNAL_SERVER_ERROR . " " . status_message(HTTP_INTERNAL_SERVER_ERROR)
      ],
      $q->start_html . "\nUnknown Error\n" . $q->end_html
    );

    print $response->headers->as_string . "\n\n";
    print $response->content . "\n";
  };
  return 1;
}

main;
