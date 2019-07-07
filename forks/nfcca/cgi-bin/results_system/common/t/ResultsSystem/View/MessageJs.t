use strict;
use warnings;
use Test::More;
use Test::Exception;
use Data::Dumper;
use Test::Differences;
use Helper qw/ get_factory /;

use_ok('ResultsSystem::View::MessageJs');

my $js;
ok( $js = get_factory()->get_message_js_view, "Got an object" );
isa_ok( $js, 'ResultsSystem::View::MessageJs' );

ok( $js->set_capture_output(1), "set_capture_output" );
ok( $js->get_capture_output,    "capture_output is true" );

lives_ok( sub { $js->run }, 'run() lives.' );

my $expected = <<'JS';
Content-Type: text/javascript; charset=ISO-8859-1
Status: 200 OK



JS

eq_or_diff_text( $js->get_captured_output, $expected, "No data" );

$expected = <<'JS';
Content-Type: text/javascript; charset=ISO-8859-1
Status: 200 OK


Help
JS

lives_ok(
  sub {
    $js->run(
      { -data        => 'Help',
        -status_code => 'HTTP_OK'
      }
    );
  },
  'run() lives.'
);

eq_or_diff_text( $js->get_captured_output, $expected, "Simple string" );

$expected = <<'JS';
Content-Type: text/javascript; charset=ISO-8859-1
Status: 200 OK


alert('Help');
JS

lives_ok(
  sub {
    $js->run(
      { -data        => "alert('Help');",
        -status_code => 'HTTP_OK'
      }
    );
  },
  'run() lives.'
);

eq_or_diff_text( $js->get_captured_output, $expected, "More realistic example." );

done_testing;

