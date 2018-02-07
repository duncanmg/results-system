use strict;
use warnings;
use Test::More;

{
package Conf;
  sub new {
    return bless {};
  }

  sub get_path { return "/tmp/results-system/forks/nfcca/results_system/fixtures/nfcca/2016"; }
  sub get_season { return 2016 }
  sub get_system { return "nfcca" }
}

use_ok('ResultsSystem::Model::WeekData::Reader');

my $wd;
ok($wd = ResultsSystem::Model::WeekData::Reader->new( {-configuration => Conf->new()}), "Object created");

# /tmp/results-system/forks/nfcca/results_system/fixtures/nfcca/2016/U9S_14-May.dat

  ok($wd->set_week('14-May'),"set_week");;

  ok($wd->set_division('U9S.csv'),"set_division");

  ok($wd->read_file(), "read_file");

done_testing;

