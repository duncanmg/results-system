use strict;
use warnings;

use Test::More;

use_ok('ResultsSystem::Logger');

my $logger;
ok( $logger = ResultsSystem::Logger->new(), "Got a logger. No arguments" );
is( $logger->get_log_dir, undef, "get_logdir" );
like( $logger->logfile_name, qr/^\/rs\d+\.log/,
  "By default logfile_name begin with 'rs' and ends with '.log'" );

$logger->screen_logger('ResultsSystem::Logger')->debug('XX');

done_testing;
