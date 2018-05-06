use strict;
use warnings;
use Test::More;

use_ok('ResultsSystem::Exception');

my $e;
ok( $e = ResultsSystem::Exception->new( 'NO_SYSTEM', 'System is not set.' ), "Got an object" );
isa_ok( $e = ResultsSystem::Exception->new( 'NO_SYSTEM', 'System is not set.' ),
  'ResultsSystem::Exception', "Got an object" );

is( $e->get_code,    'NO_SYSTEM',          'code ok' );
is( $e->get_message, 'System is not set.', 'message ok' );
ok( !$e->get_previous, "No previous exception" );
is( $e . "", 'NO_SYSTEM,System is not set.' . "\n", 'Exception stringifies correctly.' );

my $e2;
ok( $e2 = ResultsSystem::Exception->new( 'MIDDLE', 'Middle exception', $e ), "Got an object" );

is( $e2->get_code,               'MIDDLE',    'code ok' );
is( $e2->get_previous->get_code, 'NO_SYSTEM', 'Previous error ok' );
is(
  $e2 . "",
  "MIDDLE,Middle exception,NO_SYSTEM,System is not set.\n",
  'Nested errors stringify correctly'
);

my $e3;
ok( $e3 = ResultsSystem::Exception->new( 'OUTER', 'Outer exception', $e2 ), "Got an object" );
is(
  $e3 . "",
  "OUTER,Outer exception," . "MIDDLE,Middle exception,NO_SYSTEM,System is not set.\n",
  'Nested errors stringify correctly'
);

ok( $e = ResultsSystem::Exception->new(), "Got an empty object" );
is( $e . "", ",\n", "Stringifies correctly" );

done_testing;

