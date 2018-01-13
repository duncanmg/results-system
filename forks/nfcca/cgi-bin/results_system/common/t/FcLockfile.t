use strict;
use warnings;

use Test::More;

use_ok('FcLockfile');

use Helper qw/get_config get_logger/;
my $config = get_config();
my $lock_dir = $config->get_path( '-log_dir' => 'Y' );

my $locker = FcLockfile->new( -lock_dir => $lock_dir, -logger => get_logger($config) );

is( $locker->get_lock_dir, $lock_dir, "Lock dir set. " . $lock_dir );

ok( !$locker->open_lock_file('test'), "Lock file created" );

my $lock_file;
ok( $lock_file = $locker->get_lock_file, "Got a lock file name. " . $lock_file );

ok( lock_file_exists($lock_file), "Lock file exists" );

$FcLockfile::TIMEOUT = 5;
my $start = time();
ok( !$locker->open_lock_file('test'), "Lock file cannot be re-created" );
my $end = time();
is( $end - $start, 5, "Timed out after 5 seconds" );

ok( lock_file_exists($lock_file), "Lock file still exists" );

ok( !$locker->close_lock_file, "Closed lock file" );

ok( !lock_file_exists($lock_file), "Lock file no longer exists" );

ok( !$locker->open_lock_file('test'), "Lock file re-created" );
ok( lock_file_exists($lock_file),     "Lock file exists" );

$FcLockfile::TIMEOUT = 5;

$locker = undef;
ok( !lock_file_exists($lock_file), "Lock file deleted during DESTROY" );

done_testing;

sub lock_file_exists {
  my $lock_file = shift;
  ok( $lock_file, "Got a lock file name " . $lock_file );
  return ( -f $lock_file ) ? 1 : undef;
}

