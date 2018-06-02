use strict;
use warnings;
use Test::More;
use Test::Differences;
use Helper qw/get_factory/;
use Test::Exception;
use Test::MockObject;

use_ok('ResultsSystem::Model::WeekFixtures::Adapter');

my $adapter;
ok( $adapter = get_factory()->get_week_fixtures_adapter_model, "Got an object" );
isa_ok( $adapter, 'ResultsSystem::Model::WeekFixtures::Adapter' );

throws_ok(
  sub { $adapter->adapt },
  qr/Mandatory\sparameter\s'-fixtures'\smissing\sin\scall/x,
  "Throws with missing parameter."
);

throws_ok(
  sub { $adapter->adapt( { -fixtures => 'wrong' } ); },
  qr/which\sis\snot\sone\sof\sthe\sallowed\stypes:\sarrayref/x,
  "Throws with wrong parameter type."
);

eq_or_diff( $adapter->adapt( { -fixtures => [] } ), [], "Empty array ref" );

my $fixtures = [ { home => 'A', away => 'B' }, { home => 'C', away => 'D' } ];

my $expected = [ map { { team => $_ } } qw/ A B C D / ];

eq_or_diff( $adapter->_get_team_names($fixtures), $expected, "_get_team_names" );

my $mock_results = Test::MockObject->new;
$mock_results->mock(
  'get_default_result',
  sub {
    return [
      { name => 'A', value => 1 },
      { name => 'B', value => 2 },
      { name => 'C', value => 3 }
    ];
  }
);

ok( $adapter->set_week_results($mock_results), "Use mock_results" );

$expected = [
  { team => 'A', 'A' => 1, 'B' => 2, 'C' => 3 },
  { team => 'B', 'A' => 1, 'B' => 2, 'C' => 3 },
  { team => 'C', 'A' => 1, 'B' => 2, 'C' => 3 },
  { team => 'D', 'A' => 1, 'B' => 2, 'C' => 3 },
];
eq_or_diff( $adapter->adapt( { -fixtures => $fixtures } ), $expected, "_get_team_names" );

done_testing;
