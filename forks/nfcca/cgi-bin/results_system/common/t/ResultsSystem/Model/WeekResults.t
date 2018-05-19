use strict;
use warnings;
use Test::More;
use Test::Exception;
use List::MoreUtils qw/any/;
use Helper qw/get_config get_logger/;

use_ok('ResultsSystem::Model::WeekResults');

my $config = get_config;

my $wd;
ok(
  $wd = ResultsSystem::Model::WeekResults->new(
    { -config => $config, -logger => get_logger($config) }
  ),
  "Created a WeekResults object."
);

done_testing;
