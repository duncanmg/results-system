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

done_testing;
