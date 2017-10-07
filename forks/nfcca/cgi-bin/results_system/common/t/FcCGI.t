use strict;
use warnings;
use Test::More;

use_ok('FcCGI');
use CGI;

my $fc = FcCGI->new();
isa_ok( $fc, "FcCGI", "Got an FcCGI object." );

my $cgi = CGI->new();
isa_ok( $cgi, 'CGI', 'Got a CGI object' );

is( $fc->start_html(), $cgi->start_html(),
  "Both FcCGI and CGI return same string for start_html()" );

my $html5 = $fc->start_html( -html5 => 1 );
like( $html5, qr/<body>\s*$/,          "html5 still contains <body>" );
like( $html5, qr/<head>.*<\/head>/xms, "html5 still contains a head element" );
like( $html5, qr/<!DOCTYPE\shtml>\n/x, "html5 starts with correct DOCTYPE" );

done_testing;

