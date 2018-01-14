use strict;
use warnings;
use Test::More;

use_ok('Logger');

my $log;
ok( $log = Logger->new(), "Got an object" );
isa_ok( $log, "Logger" );

# Writes to standard error because no filename has been provided.
ok(!$log->logger,"Returns undef because no file has been provided.");

ok( !$log->logfile_name, "logfile_name returns undef when called without a directory" );
my $logfile_name = $log->logfile_name("/tmp");
ok( $logfile_name, "logfile_name returns a name when called with a directory" );
like( $logfile_name, qr/^\/tmp\/rs\d\d\.log$/, "Name $logfile_name matches pattern" );
is( $logfile_name, $log->logfile_name, "Once set, the logfile_name is remembered." );

ok($log->logger("/tmp"),"Returns a logger");

# Write to log file in /tmp.
$log->logger( "/tmp", 1 )->error("Log to file.");

# Write to standard error because directory does not exist.
ok(!$log->logger( "/idonotexist", 1 ),"Returns undef because directory does not exist.");

ok($log->screen_logger,"Returns a screen logger.");

$log->screen_logger->error("Screen logger");

done_testing;
