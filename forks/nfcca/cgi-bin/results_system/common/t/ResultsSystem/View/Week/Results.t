use strict;
use warnings;
use Test::More;
use Helper qw/get_factory/;

use_ok('ResultsSystem::View::Week::Results');

my $factory;
ok( $factory = get_factory, "Got a factory" );

ok( $factory->get_configuration->set_csv_file('U9N.csv'), "Set csv file" );
ok( $factory->get_configuration->set_matchdate('8-May'),  "Set match date" );

my $res;
ok( $res = $factory->get_week_results_view, "Got an object from factory" );
isa_ok( $res, 'ResultsSystem::View::Week::Results' );

is(
  $res->get_results_html_full_filename,
  $factory->get_configuration->get_path( results_dir_full => 'Y' ) . '/U9N_8-May.htm',
  "get_results_html_full_filename"
);

ok(
  $res->run(
    { -data => {
        -rows     => [],
        SYSTEM    => "",
        week      => "",
        MENU_NAME => "",
        TIMESTAMP => localtime() . "",
      }
    }
  ),
  "run executes with unrealistic data"
);

done_testing;

