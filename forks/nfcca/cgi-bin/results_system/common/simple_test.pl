#! /usr/bin/perl

=head1

Simple script to check that results_system.pl compiles correctly in situ.

simple_test.pl?pwd=testrs

=cut

use CGI;

my $cgi = CGI->new();

if ( ! $cgi->param( "pwd" ) ) {
  my $pwd = shift @ARGV;
  $cgi->param( "pwd", $pwd );
}
die "No password" if $cgi->param( "pwd" ) ne "testrs";

print $cgi->header;
print $cgi->start_html;

# my $cmd = require "results_system.pl";
# $cmd .= "&system=" . $cgi->param( "system" ) if $cgi->param( "system" );

eval { require "results_system.pl"; };
print $@ if $@;

eval { require "menu_js.pl"; };
print $@ if $@;


print $cgi->end_html;


