use strict;
use warnings;
use Test::More;
use Test::Differences;
use Helper qw/ get_factory /;

use_ok('ResultsSystem::Model::TablesIndex');
my $ti;
ok( $ti = get_factory->get_tables_index_model, "Got an object" );
isa_ok( $ti, 'ResultsSystem::Model::TablesIndex' );

eq_or_diff(
  $ti->run,
  { divisions => [
      { link => '/results_system/custom/nfcca/2017/tables/U9N.htm',
        name => 'U9N'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U9S.htm',
        name => 'U9S'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U11Elevens.htm',
        name => 'U11 Elevens'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U11N.htm',
        name => 'U11N'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U11S.htm',
        name => 'U11S'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U13N.htm',
        name => 'U13N'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U13S.htm',
        name => 'U13S'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U15N.htm',
        name => 'U15N'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U15S.htm',
        name => 'U15S'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U17.htm',
        name => 'U17'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U13Girls.htm',
        name => 'U13 Girls'
      },
      { link => '/results_system/custom/nfcca/2017/tables/U15Girls.htm',
        name => 'U15 Girls'
      }
    ],
    return_to_title => 'Return To Index',
    return_to_url   => '/index.php',
    title           => 'New Forest Colts Cricket Association 2017'
  },
  "run"
);

done_testing;

