use strict;
use warnings;
use Test::More;
use Helper qw/ get_factory /;

use_ok('ResultsSystem::Factory');

my @methods = qw /
  get_auto_cleaner
  get_blank_controller
  get_blank_view
  get_configuration
  get_file_logger
  get_fixture_list_model
  get_frame_controller
  get_frame_model
  get_frame_view
  get_full_filename
  get_league_table_model
  get_league_table_view
  get_locker
  get_logger
  get_menu_controller
  get_menu_js_controller
  get_menu_js_model
  get_menu_js_view
  get_menu_model
  get_menu_view
  get_message_view
  get_pwd_model
  get_pwd_view
  get_results_index_controller
  get_results_index_model
  get_results_index_view
  get_router
  get_save_results_controller
  get_save_results_model
  get_screen_logger
  get_starter
  get_system
  get_tables_index_controller
  get_tables_index_model
  get_tables_index_view
  get_week_data_reader_model
  get_week_data_reader_model_factory
  get_week_data_writer_model
  get_week_fixtures_adapter_model
  get_week_fixtures_controller
  get_week_fixtures_selector_model
  get_week_fixtures_view
  get_week_results_view
  get_store_divisions_model
  /;

my $factory;
ok( $factory = get_factory, "Got an object" );
isa_ok( $factory, 'ResultsSystem::Factory' );

foreach my $m (@methods) {

  next if $m =~ m/get_system|get_full_filename/x;    # Investigate these!

  ok( $factory->$m, $m );
}

done_testing;

