#! /usr/bin/perl

BEGIN { unshift @INC, '/home/hantscl/perl5/lib/perl5/x86_64-linux-thread-multi','/home/hantscl/perl5/lib/perl5' };

use strict;
use CGI;

my $cgi = CGI->new();

print $cgi->header; 
print $cgi->start_html;
print "Hello";
print $cgi->end_html;

