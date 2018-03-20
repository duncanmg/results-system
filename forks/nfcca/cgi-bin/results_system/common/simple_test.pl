#! /usr/bin/perl

=head1

Simple script to check that results_system.pl compiles correctly in situ.

simple_test.pl?pwd=testrs

=cut

use strict;
use warnings;
use Carp;
use CGI;

my $cgi = CGI->new();

if ( !$cgi->param("pwd") ) {
  my $pwd = shift @ARGV;
  $cgi->param( "pwd", $pwd );
}
croak "No password" if $cgi->param("pwd") ne "testrs";

print $cgi->header;
print $cgi->start_html;

print "<p>";
my $ok = eval {
  require "results_system.pl";    ## no critic (RequireBarewordIncludes)
  1;
};
print $ok ? "results_system.pl compiles" : $@;
print "</p>";

print $cgi->end_html;

