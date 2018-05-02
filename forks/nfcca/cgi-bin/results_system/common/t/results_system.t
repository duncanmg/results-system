use strict;
use warnings;
use Test::More;

use LWP;
use HTTP::Request::Common;
use WebService::Validator::HTML5::W3C;

my $user     = 'NFCCA';
my $password = $ENV{'NFCCA_CODE'};

my $perl_version = $];
if ( $perl_version < 5.020002 ) {
  plan skip_all =>
    "LWP needs a recent version of Perl to retrieve large files. Got $perl_version, need 5.020002";

}

my $lwp       = LWP::UserAgent->new();
my $validator = WebService::Validator::HTML5::W3C->new();

my $base = 'http://www.results_system_nfcca.com';

my $static_tables_url  = $base . '/results_system/custom/nfcca/2017/tables';
my $static_results_url = $base . '/results_system/custom/nfcca/2017/results';

my $gets = [
  { url     => $base . '/cgi-bin/results_system/common/results_system.pl?system=nfcca&page=frame',
    pattern => 'iframe_holder_menu.*iframe_holder_detail'
  },
  { url     => $base . '/cgi-bin/results_system/common/results_system.pl?system=nfcca&page=blank',
    pattern => 'Results\sSystem.*<p>\&nbsp;<\/p>'
  },
  { url     => $base . '/cgi-bin/results_system/common/results_system.pl?system=nfcca&page=menu',
    pattern => 'Results\sSystem.*Display\sFixtures'
  },
  { url     => $static_tables_url . '/U9N.htm',
    pattern => 'Results\sSystem.*Division.*U9N'
  },
  { url     => $static_results_url . '/U9N_1-May.htm',
    pattern => 'Results\sSystem.*Results\sFor\sDivision'
  },
];

my $posts = [
  { url  => $base . '/cgi-bin/results_system/common/results_system.pl',
    data => [
      system     => 'nfcca',
      page       => 'week_fixtures',
      'division' => 'U9N.csv',
      matchdate  => '1-May'
    ],
    pattern => 'Results\sSystem.*<h1>Fixtures\sFor\sDivision\sU9N\sWeek\s1-May<\/h1>'
  },
  { url  => $base . '/cgi-bin/results_system/common/results_system.pl',
    data => [
      system     => 'nfcca',
      page       => 'save_results',
      'division' => 'U9N.csv',
      matchdate  => '1-May',
      user       => $user,
      code       => $password,
    ],
    pattern => 'Your\schanges\shave\sbeen\saccepted'
  },
  { url  => $base . '/cgi-bin/results_system/common/results_system.pl',
    data => [
      system     => 'nfcca',
      page       => 'save_results',
      'division' => 'U9N.csv',
      matchdate  => '1-May',
      user       => $user,
      code       => 'wrong',
    ],
    pattern     => 'You\shave\sentered\san\sincorrect\spassword.',
    status_code => 401
  },

];

foreach my $g (@$gets) {
  test_get($g);
}

foreach my $p (@$posts) {
  test_post($p);
}

done_testing;

# ********************************************************************
sub test_post {
  my $hr = shift;

  my $response = $lwp->request(
    POST $hr->{url},
    Content_Type => 'form-data',
    Content      => $hr->{data}
  );

  my $content = $response->content;

  validate( $hr->{url}, $content );
  like( $response->content, qr/$hr->{pattern}/xms, "Content matches pattern $hr->{pattern}" );
  is( $response->code, ( $hr->{status_code} || 200 ), "Status code ok." );
}

# ********************************************************************
sub test_get {
  my $hr = shift;
  my $response = $lwp->request( GET $hr->{url}, Content_Type => 'text/html' );

  validate( $hr->{url}, $response->content );
  like( $response->content, qr/$hr->{pattern}/xms, "Content matches pattern $hr->{pattern}" );
}

# ********************************************************************
sub validate {
  my ( $url, $content ) = @_;
  ok( $validator->validate_direct_input($content), "$url returns valid HTML5" )
    || do {
    print_errors( $validator->errors );
    print "\n\n" . $content;
    };
  return 1;
}

# ********************************************************************
sub print_errors {
  my $errors = shift;
  foreach my $e ( @{$errors} ) {
    print "\n" . $e . "\n";
  }
  return 1;
}
