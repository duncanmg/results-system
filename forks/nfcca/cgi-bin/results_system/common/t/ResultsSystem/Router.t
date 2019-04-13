use strict;
use warnings;
use Test::More;
use Helper qw/get_factory/;
use Test::MockObject;

use_ok('ResultsSystem::Router');

my $r;
ok( $r = get_factory->get_router, "Got object" );
isa_ok( $r, 'ResultsSystem::Router' );

my $mock      = Test::MockObject->new;
my $mock_page = sub { return 1; };

foreach my $p (
  qw/ get_frame_controller get_menu_controller get_blank_controller get_menu_js_controller
  get_week_fixtures_controller get_pwd_controller get_save_results_controller get_league_table_controller
  get_week_results_controller get_results_index_controller get_tables_index_controller get_message_view  /
  )
{
  $mock->mock( $p, $mock_page );
}
$mock->mock( 'get_file_logger', sub { shift; return get_factory->get_file_logger(@_); } );

ok( $r->set_pages($mock), "set_factory" );

foreach my $p (
  qw/ frame menu blank menu_js week_fixtures save_results results_index tables_index donotexise /)
{
  my $mock_cgi = Test::MockObject->new;
  $mock_cgi->mock( 'param', sub {$p} );
  ok( $r->route($mock_cgi), "$p" );
}

done_testing;
