#! /usr/bin/perl

=head1 NAME

results_system.pl

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

use strict;
use warnings;

BEGIN {
  use LoadEnv;
  LoadEnv::run();
}

use CGI;
use Params::Validate qw/:all/;
use Data::Dumper;
use HTTP::Response;
use HTTP::Status qw/:constants status_message/;

use ResultsSystem;

=head1 FUNCTIONS

=cut

=head2 main

=cut

# ******************************************************
sub main {

  # ******************************************************

  my $q;
  eval {
    $q = CGI->new();

    my $rs = ResultsSystem->new();

    $rs->get_starter->start( $q->param('system'), $q->param('division'), $q->param('matchdate') );
    $rs->get_factory->get_auto_cleaner->auto_clean;

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

main if !caller;

1;

