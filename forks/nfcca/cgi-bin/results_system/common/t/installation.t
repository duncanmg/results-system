use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::File;

use File::Path qw/remove_tree/;

require_ok('installation.pl');

ok( !$ENV{NFCCA_PASSWD}, "ENV{NFCCA_PASSWD} not set" );
throws_ok( sub { main( {} ) }, qr/PASSWD/, "Dies when no password" );
$ENV{NFCCA_PASSWD} = "xyz";
ok( $ENV{NFCCA_PASSWD}, "ENV{NFCCA_PASSWD} set" );
lives_ok( sub { main( {} ) }, "Lives when password" );

#ok( !$ENV{NFCCA_PASSWD}, "ENV{NFCCA_PASSWD} not set" );

my $test_dir = "/tmp/nfcca_installation";

ok( set_up(), "set_up complete" );

my $options = { rollforward => 1, mirror_base => $test_dir, passwd => 'xyz' };
ok( main($options), "rollforward" );

file_exists_ok("$test_dir/last/current_file.txt");
file_not_exists_ok("$test_dir/last/last_file.txt");

file_exists_ok("$test_dir/current/next_file.txt");
file_not_exists_ok("$test_dir/current/current_file.txt");

file_exists_ok("$test_dir/next/next_file.txt");
file_not_exists_ok("$test_dir/next/current_file.txt");

ok( set_up(), "set_up complete" );

$options = { rollback => 1, mirror_base => $test_dir, passwd => 'xyz' };
ok( main($options), "rollback" );

file_not_exists_ok("$test_dir/last/current_file.txt");
file_exists_ok("$test_dir/last/last_file.txt");

file_exists_ok("$test_dir/current/last_file.txt");
file_not_exists_ok("$test_dir/current/current_file.txt");

file_not_exists_ok("$test_dir/next/next_file.txt");
file_exists_ok("$test_dir/next/current_file.txt");

done_testing;

# ******************************************************************************

sub create_dirs {
  my $dirs = shift;
  foreach my $d (@$dirs) {
    ok( mkdir($d), "Created $d" ) || last;
  }
  1;
}

sub create_file {
  my ( $file, $msg ) = @_;
  my $FP;
  $msg ||= "";
  ok( open( $FP, ">", $file ), "$file opened" ) || return;
  ok( ( print $FP ( $msg || "none" ) ), "Message written" ) || return;
  ok( close($FP), "File closed" ) || return;
  1;
}

sub set_up {

  remove_tree $test_dir if -d $test_dir;
  ok( !( -d $test_dir ), "$test_dir does not exist" );

  my $current = "$test_dir/current";
  my $next    = "$test_dir/next";
  my $last    = "$test_dir/last";
  create_dirs( [ $test_dir, "$current", "$last", "$next" ] ) || return;
  my @files = (
    [ "$current/current_file.txt", "Current" ],
    [ "$next/next_file.txt",       "Next" ],
    [ "$last/last_file.txt",       "Last" ]
  );
  foreach my $f (@files) {
    ok( create_file(@$f), "Added $f->[0]" );
  }
  1;
}

