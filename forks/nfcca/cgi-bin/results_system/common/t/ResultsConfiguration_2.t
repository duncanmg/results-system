use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;

use_ok('ResultsConfiguration');

my $config;
ok( $config = ResultsConfiguration->new(), "Object created." );
isa_ok( $config, 'ResultsConfiguration' );

ok( !$config->get_full_filename(), "Full file name is not set." );

my ( $main_filename, $local_filename );

$config->{FULL_FILENAME} = "banana";
( $main_filename, $local_filename ) = $config->_get_local_and_main_filenames();
is( $main_filename, "banana", "Main filename ok" );
ok( !$local_filename, "No local filename" );

test_file_naming( "banana",           "banana",       undef );
test_file_naming( "banana.ini",       "banana.ini",   undef );
test_file_naming( "banana_local.ini", "banana.ini",   "banana_local.ini" );
test_file_naming( "banana_local",     "banana_local", undef );

cmp_deeply( $config->_merge_files( {}, {} ), {}, "Empty hashes merged successfully" );

cmp_deeply(
  $config->_merge_files( { 'y' => 1 }, { 'x' => 2 } ),
  { 'x' => 2 },
  "Only specific keys are merged successfully"
);

cmp_deeply(
  $config->_merge_files( { 'paths' => 1 }, { 'x' => 2 } ),
  { 'paths' => 1, 'x' => 2 },
  "The key 'paths' is merged successfully"
);

cmp_deeply(
  $config->_merge_files( { 'paths' => 1 }, { 'x' => 2, 'paths' => 10 } ),
  { 'paths' => 1, 'x' => 2 },
  "The key 'paths' is over-written successfully"
);

cmp_deeply(
  $config->_merge_files(
    { paths        => 1,
      descriptors  => 2,
      return_to    => 3,
      stylesheets  => 4,
      divisions    => 5,
      users        => 7,
      calculations => 8
    },
    { paths       => 11,
      descriptors => 12,
      return_to   => 13,
      stylesheets => 14,
      divisions   => 15,
      users       => 17,
      dummy       => 20,
    }
  ),
  { paths        => 1,
    descriptors  => 2,
    return_to    => 3,
    stylesheets  => 4,
    divisions    => 5,
    users        => 7,
    calculations => 8,
    dummy        => 20,
  },
  "All appropriate keys merged successfully"
);

sub test_file_naming {
  my ( $main_filename, $main_result, $local_result ) = @_;
  $config->{FULL_FILENAME} = $main_filename;
  my ( $main, $local ) = $config->_get_local_and_main_filenames();
  is( $main,  $main_result,  "Main filename ok" );
  is( $local, $local_result, "Local filename ok" );
}

#  -full_filename => "dummy.ini"

# TODO Test merging
#

done_testing;
