#! /usr/bin/perl

use CGI;

my $q = CGI->new();

print $q->header;
print $q->start_html;
print "<h1>Hello</h1>\n";
print $q->end_html;

