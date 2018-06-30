use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Differences;

use Helper qw/ get_factory get_example_csv_full_filename /;

use_ok('ResultsSystem::Model::FixtureList');

my $fl;
ok( $fl = get_factory->get_fixture_list_model, "Got an object" );
isa_ok( $fl, 'ResultsSystem::Model::FixtureList' );
ok( $fl->logger,            "Logger is set" );
ok( $fl->get_configuration, "Configuration is set" );

throws_ok( sub { $fl->read_file },
  qr/FILE_DOES_NOT_EXIST/x, "read_file throws an exception because the file has not been set." );

ok( $fl->set_full_filename( get_example_csv_full_filename() ), "Set full_filename" );

lives_ok( sub { $fl->read_file }, "Full filename has been set so read_file() lives" );

my $date_list = $fl->get_date_list;
is( ref($date_list), 'ARRAY', "get_date_list returns an array ref" );
ok( scalar(@$date_list) > 1, "Got at least 1 date" );

my $date = shift @$date_list;

my $wf;
ok( $wf = $fl->get_week_fixtures( -date => $date ), "get_week_fixtures" );
ok( scalar(@$wf) > 1, "Got at least 1 fixture for $date" );
eq_or_diff(
  [ sort( keys( %{ $wf->[0] } ) ) ],
  [ 'away', 'home' ],
  "First fixture has the correct keys"
);

done_testing;

