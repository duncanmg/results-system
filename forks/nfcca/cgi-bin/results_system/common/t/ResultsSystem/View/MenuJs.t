use strict;
use warnings;
use Test::More;
use Test::Differences;
use Helper qw/ get_factory /;

use_ok('ResultsSystem::View::MenuJs');

my $v;
ok( $v = get_factory->get_menu_js_view, "Got an object" );
isa_ok( $v, 'ResultsSystem::View::MenuJs' );

ok( $v->set_capture_output(1), "set_capture_output" );

my $test_data = {
  -data => {
    'all_dates' => {
      'U11Elevens.csv' => [
        '1-May',  '8-May',  '15-May', '22-May', '5-Jun', '12-Jun',
        '19-Jun', '26-Jun', '3-Jul',  '10-Jul'
      ],
      'U13Girls.csv' => [
        '1-May',  '8-May',  '15-May', '22-May', '5-Jun', '12-Jun',
        '19-Jun', '26-Jun', '3-Jul',  '10-Jul'
      ],
      'U17.csv' => [
        '1-May',  '8-May',  '15-May', '22-May', '5-Jun', '12-Jun',
        '19-Jun', '26-Jun', '3-Jul',  '10-Jul'
      ],
    },

    'menu_names' => 'if ( typeof( menu_names ) == "undefined" ) 
              { menu_names = new Array(); }
            if ( typeof( csv_files ) == "undefined" ) { csv_files = new Array(); }
            
            menu_names.push( "U11 Elevens" );
            csv_files.push( "U11Elevens.csv" );
            
            menu_names.push( "U17" );
            csv_files.push( "U17.csv" );
            
            menu_names.push( "U13 Girls" );
            csv_files.push( "U13Girls.csv" );
            '
  }
};

my $expected = <<'JS';
Content-Type: text/javascript; charset=ISO-8859-1
Status: 200 OK


var all_dates = {"U11Elevens.csv":["1-May","8-May","15-May","22-May","5-Jun","12-Jun","19-Jun","26-Jun","3-Jul","10-Jul"],"U13Girls.csv":["1-May","8-May","15-May","22-May","5-Jun","12-Jun","19-Jun","26-Jun","3-Jul","10-Jul"],"U17.csv":["1-May","8-May","15-May","22-May","5-Jun","12-Jun","19-Jun","26-Jun","3-Jul","10-Jul"]};

if ( typeof( menu_names ) == "undefined" ) 
              { menu_names = new Array(); }
            if ( typeof( csv_files ) == "undefined" ) { csv_files = new Array(); }
            
            menu_names.push( "U11 Elevens" );
            csv_files.push( "U11Elevens.csv" );
            
            menu_names.push( "U17" );
            csv_files.push( "U17.csv" );
            
            menu_names.push( "U13 Girls" );
            csv_files.push( "U13Girls.csv" );
            
JS

ok( $v->run($test_data), "run" );

eq_or_diff(
  [ split( "\n", $v->get_captured_output ) ],
  [ split( "\n", $expected ) ],
  "captured_output", { context => 3 }
);

done_testing;

