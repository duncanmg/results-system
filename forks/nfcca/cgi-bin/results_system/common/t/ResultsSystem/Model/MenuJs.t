use strict;
use warnings;
use Test::More;
use Test::Exception;
use Data::Dumper;

use Helper qw/ get_factory /;

use_ok('ResultsSystem::Model::MenuJs');

my $js;
ok( $js = get_factory()->get_menu_js_model, "Got an object" );
isa_ok( $js, 'ResultsSystem::Model::MenuJs' );

my $data;
lives_ok( sub { $data = $js->run }, 'run() lives.' );

is( ref($data), 'HASH', 'Got a hash ref' );

ok( exists( $data->{all_dates} ),  'Key all_dates exists' );
ok( exists( $data->{menu_names} ), 'Key menu_names exists' );

done_testing;

