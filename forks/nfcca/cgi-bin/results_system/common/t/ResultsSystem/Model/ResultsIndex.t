use strict;
use warnings;
use Test::More;
use Test::Differences;
use Helper qw/get_factory/;

use_ok('ResultsSystem::Model::ResultsIndex');

my $ri;
ok( $ri = get_factory->get_results_index_model, "Got an object from factory" );
isa_ok( $ri, 'ResultsSystem::Model::ResultsIndex' );

my $index = $ri->run;
ok( scalar(@$index) > 0, "run() returned array ref with at least 1 row" );

my $out;
ok( $out = $ri->run, "run()" );

my $expected = [
  { dates => [
      { matchdate => '1-May',
        url       => '/results_system/custom/nfcca/2017/results/U9N_1-May.htm'
      },
      { matchdate => '8-May',
        url       => '/results_system/custom/nfcca/2017/results/U9N_8-May.htm'
      },
      { matchdate => '15-May',
        url       => '/results_system/custom/nfcca/2017/results/U9N_15-May.htm'
      },
    ],
    division  => 'U9N.csv',
    menu_name => 'U9N'
  },
  { dates     => [],
    division  => 'U9S.csv',
    menu_name => 'U9S'
  },
  { dates     => [],
    division  => 'U11Elevens.csv',
    menu_name => 'U11 Elevens'
  },
  { dates     => [],
    division  => 'U11N.csv',
    menu_name => 'U11N'
  },
  { dates     => [],
    division  => 'U11S.csv',
    menu_name => 'U11S'
  },
  { dates     => [],
    division  => 'U13N.csv',
    menu_name => 'U13N'
  },
  { dates     => [],
    division  => 'U13S.csv',
    menu_name => 'U13S'
  },
  { dates     => [],
    division  => 'U15N.csv',
    menu_name => 'U15N'
  },
  { dates     => [],
    division  => 'U15S.csv',
    menu_name => 'U15S'
  },
  { dates     => [],
    division  => 'U17.csv',
    menu_name => 'U17'
  },
  { dates     => [],
    division  => 'U13Girls.csv',
    menu_name => 'U13 Girls'
  },
  { dates     => [],
    division  => 'U15Girls.csv',
    menu_name => 'U15 Girls'
  }
];

eq_or_diff(
  $out->[0]->{dates}->[0],
  $expected->[0]->{dates}->[0],
  "Test first element, first date"
);

eq_or_diff( $out->[0], $expected->[0], "Test first element, which is U9N" );

eq_or_diff( $out, $expected, "Test the whole structure" );

done_testing;

