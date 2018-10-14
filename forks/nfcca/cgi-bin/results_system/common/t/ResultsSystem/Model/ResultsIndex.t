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

eq_or_diff(
  $ri->run,
  [ { dates => [
        { file =>
            '/home/duncan/git/results_system/forks/nfcca/results_system/fixtures/nfcca/2017/U9N_1-May.dat',
          matchdate => '1-May'
        },
        { file =>
            '/home/duncan/git/results_system/forks/nfcca/results_system/fixtures/nfcca/2017/U9N_8-May.dat',
          matchdate => '8-May'
        },
        { file =>
            '/home/duncan/git/results_system/forks/nfcca/results_system/fixtures/nfcca/2017/U9N_15-May.dat',
          matchdate => '15-May'
        }
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
  ]

  ,
  "run() returned correct data"
);

done_testing;

