use strict;
use warnings;
use Test::More;
use Test::Exception;

use Helper qw/ get_config/;

use_ok('ResultsSystem::Configuration');

my $config = get_config;

$config->logger->less_logging(4);    # Disable logging

# These paths must return a directory which exists.
foreach my $p (
  qw/ -csv_files -log_dir -pwd_dir
  -root -cgi_dir_full -htdocs_full
  -results_dir_full -table_dir_full/
  )
{
  my $ff = $config->get_path( $p => "Y" ) || "";
  ok( ( -d $ff ), "$ff is a directory. " . $p );
}

# These path must return something, but it may be a relative
# path, so we can't test if it exists.
foreach my $p (
  qw/ -csv_files -log_dir -pwd_dir -table_dir
  -htdocs -cgi_dir -root /
  )
{
  my $ff = $config->get_path( $p => "Y", -allow_not_exists => "Y" ) || "";
  ok( $ff, "$ff is set. " . $p );
}

# This demonstrates that -allow_not_exists can be any true value.
ok( $config->get_path( "-cgi_dir_full" => "Y", -allow_not_exists => 1 ),
  "-cgi_dir_full is a valid argument" );

throws_ok( sub { $config->get_path( "-bad_path" => "Y", -allow_not_exists => 1 ) },
  qr/PATH_NOT_IN_TAGS/, "-bad_path is an invalid argument" );

lives_ok(
  sub {
    $config->get_path( "-csv_files_with_season" => "Y", -allow_not_exists => 1 );
  },
  "Path with suffix lives."
);

my $csv_files_with_season;
ok(
  $csv_files_with_season =
    $config->get_path( "-csv_files_with_season" => "Y", -allow_not_exists => 1 ),
  "$csv_files_with_season"
);
like( $csv_files_with_season, qr:nfcca\/\d{4}$:,
  "csv_files_with_season ends with the system and the year. eg nfcca/2017" );

ok( $config->set_csv_file('U9N.csv'), "set_csv_file" );
is( $config->get_csv_file, 'U9N.csv', "get_csv_file returns correct vaule" );
ok( $config->get_csv_full_filename, "get_csv_full_filename returns a true value." );
like( $config->get_csv_full_filename,
  qr/\d{4}\/U9N\.csv/, "get_csv_full_filename returns a sensible value" );

dies_ok( sub { $config->set_csv_file('XXX') },   'set_csv_file dies with XXX' );
dies_ok( sub { $config->set_csv_file() },        'set_csv_file dies with no argument' );
dies_ok( sub { $config->set_csv_file('-.csv') }, 'set_csv_file dies with bad character' );

ok( $config->set_matchdate('9-May'), "set_matchdate" );
is( $config->_get_matchdate, '9-May', "_get_matchdate reurns correct value" );
like(
  $config->get_results_full_filename,
  qr/\d{4}\/U9N_\d{1,2}-[A-Z][a-z]{2}\.dat$/x,
  "get_matchdate_full_filename returns something sensible"
);

dies_ok( sub { $config->set_matchdate('XXX') },   'set_matchdate dies with XXX' );
dies_ok( sub { $config->set_matchdate() },        'set_matchdate dies with no argument' );
dies_ok( sub { $config->set_matchdate('-.dat') }, 'set_matchdate dies with bad character' );

done_testing;
