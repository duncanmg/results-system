use strict;
use warnings;
use Test::More;
use Test::Exception;
use Data::Dumper;

use Helper qw/get_factory/;

use_ok('ResultsSystem::Model::Store');

my $store;
ok( $store = get_factory()->get_store_model, "Got an object" );
isa_ok( $store, 'ResultsSystem::Model::Store' );

my $all_fixture_lists = {};
lives_ok( sub { $all_fixture_lists = $store->get_all_fixture_lists; },
  "get_all_fixture_lists lives" );

ok( scalar( keys %$all_fixture_lists ) > 1, "Got more than 1 division" );

is( scalar( grep { ref( $all_fixture_lists->{$_} ) ne 'ARRAY' } keys %$all_fixture_lists ),
  0, 'Got a hash ref of list refs' )
  || diag( Dumper $all_fixture_lists);

is( ref( $store->get_all_week_results_for_division('U9.csv') ),
  'ARRAY', 'get_all_week_results_for_division returns array ref' );

done_testing;
