use strict;
use warnings;
use Test::More;
use Test::Exception;

use DateTime;

use_ok('ResultsSystem::Results::Result');

my ( $obj, $now );
ok( $now = DateTime->now, "Created DateTime now." );

ok( $obj = ResultsSystem::Results::Result->new( week_commencing => DateTime->now ),
  "Object created." );
isa_ok( $obj, 'ResultsSystem::Results::Result' );

ok( $obj->away_result('L'),"Set away_result to 'L'");
ok( $obj->home_result('W'),"Set home_result to 'W'");

done_testing;

