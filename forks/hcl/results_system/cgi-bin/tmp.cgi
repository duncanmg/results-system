use CGI;
my $cgi = CGI->new();

print $cgi->header;
print $cgi->start_html;
print "Hello";
print $cgi->end_html;
