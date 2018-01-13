use strict;
use warnings;
use Test::More;
use Test::Exception;
use List::MoreUtils qw/any/;
use Helper qw/get_config get_logger/;

use_ok('WeekData');
use_ok('ResultsConfiguration');

my $config = get_config;

my $wd;
ok( $wd = WeekData->new( -config => $config, -logger => get_logger($config) ),
  "Created a WeekData object." );

my @labels = (
  "team",      "played",     "result",     "runs",       "wickets",  "performances",
  "resultpts", "battingpts", "bowlingpts", "penaltypts", "totalpts", "pitchmks",
  "groundmks", "facilitiesmks"
);

my @integers =
  ( "runs", "wickets", "resultpts", "battingpts", "bowlingpts", "penaltypts", "totalpts", );

foreach my $l (@labels) {
  if ( any { $_ eq $l } @integers ) {
    foreach my $v ( 0, 5, 10 ) {
      is( $wd->set_field( -lineno => 0, -field => $l, -value => $v, -type => "line" ),
        0, "Value $v accepted for $l" );
    }
    foreach my $v ( "w", -1, 1.1 ) {
      is( $wd->set_field( -lineno => 0, -field => $l, -value => $v, -type => "line" ),
        1, "Value $v rejected for $l" );
    }
  }
}

is( $wd->set_field( -lineno => 0, -field => 'played', -value => 'Y', -type => "line" ),
  0, "Value 'Y' accepted for 'played'" );
is( $wd->set_field( -lineno => 0, -field => 'played', -value => 'N', -type => "line" ),
  0, "Value 'N' accepted for 'played'" );
is( $wd->set_field( -lineno => 0, -field => 'played', -value => 'A', -type => "line" ),
  0, "Value 'A' accepted for 'played'" );
is( $wd->set_field( -lineno => 0, -field => 'played', -value => 'X', -type => "line" ),
  1, "Value 'X' rejected for 'played'" );
is( $wd->set_field( -lineno => 0, -field => 'played', -value => undef, -type => "line" ),
  1, "Value undef rejected for 'played'" );

done_testing;
