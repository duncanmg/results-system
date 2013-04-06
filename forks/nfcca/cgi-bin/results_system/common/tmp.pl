#! /usr/bin/perl

use CGI;
  use Date::Calc qw/ Day_of_Week Decode_Month Add_Delta_Days This_Year Month_to_Text /;

my $q = CGI->new();

print $q->header;
print $q->start_html;
print "<h1>Hello ....</h1>\n";
print $q->end_html;

open( $FP, ">>", "/home/sites/newforestcricket.co.uk/results_system/logs/nfcca/tmp.tmp" );
print $FP localtime() . "\n";
close $FP;

open( $FP, ">", "/home/sites/newforestcricket.co.uk/public_html/test.htm" );
# print $FP $q->header;
print $q->start_html;
print $FP "<h1>Hello .... " . localtime() . "</h1>\n";
print $q->end_html;
close $FP;

  # **************************************
  sub _get_week_commencing {
  # **************************************
    my ( $match_date ) = ( @_ );
    my ( $d, $del, $m ) = $match_date =~ m/(\d+)(\W)(\w+)\W*$/;
    my $dow = Day_of_Week( This_Year, Decode_Month( $m ), $d );
    $dow = 0 if $dow == 7;
    print "$dow\n";
    ( $y, $m, $d ) = Add_Delta_Days( This_Year, Decode_Month( $m ), $d, $dow * -1 );
    return $d . $del . substr( Month_to_Text( $m ), 0, 3 );     
  }

print _get_week_commencing( "8-Mar" ) . "\n";
print _get_week_commencing( "12-Mar" ) . "\n";
print _get_week_commencing( "13-Mar" ) . "\n";
print _get_week_commencing( "14-Mar" ) . "\n";
print _get_week_commencing( "15-Mar" ) . "\n";

