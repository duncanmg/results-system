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

=over

=item Creates a CGI object to handle the request.

=item Creates a ResulysSystem object.

=item Uses the factory to create an SutoCleaner object and does an autoclean.

=item Pases the CGI object to the router.

=item If any of the above fail then it reurns a page with the message "Unknown Error" and code HTTP_INTERNAL_SERVER_ERROR.

=back

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

    my $response = HTTP::Response->new( HTTP_INTERNAL_SERVER_ERROR,
      status_message(HTTP_INTERNAL_SERVER_ERROR),
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

=head1 UML

=head2 Activity Diagram

=begin HTML

<p><img src="http://www.results_system_nfcca_uml.com/activity_diagram_results_system_pl.jpeg"
width="1000" height="500" alt="UML" /></p>

=end HTML

=cut

1;

