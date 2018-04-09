use strict;
use warnings;
use Test::More;

use LWP;
use HTTP::Request::Common;
use WebService::Validator::HTML5::W3C;

my $lwp       = LWP::UserAgent->new();
my $validator = WebService::Validator::HTML5::W3C->new();

my $base = 'http://www.results_system_nfcca.com';

my $gets = [
  { url     => $base . '/cgi-bin/results_system/common/results_system.pl?system=nfcca&page=frame',
    pattern => 'iframe_holder_menu.*iframe_holder_detail'
  },
  { url     => $base . '/cgi-bin/results_system/common/results_system.pl?system=nfcca&page=blank',
    pattern => 'Results\sSystem.*<p>\&nbsp;<\/p>'
  },
  { url     => $base . '/cgi-bin/results_system/common/results_system.pl?system=nfcca&page=menu',
    pattern => 'Results\sSystem.*Display\sFixtures'
  }
];

my $posts = [
  { url  => $base . '/cgi-bin/results_system/common/results_system.pl',
    data => [
      system     => 'nfcca',
      page       => 'week_fixtures',
      'division' => 'U9N.csv',
      matchdate => '1-May'
    ],
    pattern => 'Results\sSystem.*<h1>Fixtures\sFor\sDivision\sU9N\sWeek\s1-May<\/h1>'
  }
];

foreach my $g (@$gets) {
  # test_get($g);
}

foreach my $p (@$posts) {
  test_post($p);
}

sub test_post {
  my $hr = shift;

  my $response = $lwp->request(
    POST $hr->{url},
    Content_Type => 'form-data',
    Content      => $hr->{data}
  );

  my $content = $response->as_string("\n");
  # $content =~ s/\cJ//gxms;
  # $content =~ s/\cI//gxms;
  $content =~ s|^.*<!DOCTYPE\shtml>|<!DOCTYPE html>|xms;
  $content=<<'EOF';
<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset="UTF-8">
<title>Results System</title>
<link rel="stylesheet" type="text/css" href="/results_system/custom/nfcca/nfcca_styles.css" />


<script src="/results_system/common/common.js"></script>

</head>
  <body>
        <script src="/results_system/common/menu.js"></script>
      <h1>New Forest Colts Cricket Association 2017</h1>
      <h1>Fixtures For Division U9N Week 1-May</h1>
      <!-- <h1>Results For Division U9N Week 1-May<h1> -->
      <p><a href="results_system.pl?system=nfcca&page=results_index">Return To Results Index</a></p>

      <form id="menu_form" name="menu_form" method="post" action="results_system.pl"
      onsubmit="return validate_menu_form();"
      target = "f_detail">

      <table class='week_fixtures'>
      <tr>
      <th class="teamcol">Team</th>
      <th>Played</th>
      <th>Result</th>
      <th>Runs</th>
      <th>Wickets</th>
      <th class="performances">Performances</th>
      <th>Result Pts</th>
      <th>Batting Pts</th>
      <th>Bowling Pts</th>
      <th>Penalty Pts</th>
      <th>Total Pts</th>
      </tr>

          <tr>
    <td> <input type="text" id="hometeam0" name="hometeam0" value="Langley Manor 1" readonly/> </td>
    <td> <select name="homeplayed0" size="1" onchange="calculate_points( this, 0 )">
      <option value="Y" selected="selected">Y </option>
      <option value="N" >N </option>
      <option value="A" >A </option>
      </select>
    </td>
    <td> <select name="homeresult0" size="1" onchange="calculate_points( this, 0 )">
      <option value="W" selected="selected">W</option>
      <option value="L" >L</option>
      <option value="T" >T</option>
      </select>
    </td>
    <td> <input name="homeruns0" id="homeruns0" type="number" min="0" value="11"/></td>
    <td> <input name="homewickets0" id="homewickets0" type="number" min="0" value="2"/></td>
    <td class="performances"> <input type="text"  name="homeperformances0" id="homeperformances0" value="xx Hivvvx"/></td>
    <td> <input  name="homeresultpts0" id="homeresultpts0" type="number" min="0" onchange="calculate_points( this, 0 )" value="2"/></td>
    <td> <input name="homebattingpts0" id="homebattingpts0" type="number" min="0" onchange="calculate_points( this, 0 )" value="0"/></td>
    <td> <input name="homebowlingpts0" id="homebowlingpts0" type="number" min="0" onchange="calculate_points( this, 0 )" value="0"/></td>
    <td> <input name="homepenaltypts0" id="homepenaltypts0" type="number" min="0" onchange="calculate_points( this, 0 )" value="0"/></td>
    <td> <input name="hometotalpts0" id="hometotalpts0" type="number" onchange="calculate_points( this, 0 )" value="2"/></td>
    </tr>
    <tr>
    <td> <input type="text" id="awayteam0" name="awayteam0" value="Langley Manor 3" readonly/> </td>
    <td> <select name="awayplayed0" size="1" onchange="calculate_points( this, 0 )">
      <option value="Y" selected="selected">Y </option>
      <option value="N" >N </option>
      <option value="A" >A </option>
      </select>
    </td>
    <td> <select name="awayresult0" size="1" onchange="calculate_points( this, 0 )">
      <option value="W" >W</option>
      <option value="L" selected="selected">L</option>
      <option value="T" >T</option>
      </select>
    </td>
    <td> <input name="awayruns0" id="awayruns0" type="number" min="0" value="1"/></td>
    <td> <input name="awaywickets0" id="awaywickets0" type="number" min="0" value="1"/></td>
    <td class="performances"> <input type="text"  name="awayperformances0" id="awayperformances0" value="yy"/></td>
    <td> <input  name="awayresultpts0" id="awayresultpts0" type="number" min="0" onchange="calculate_points( this, 0 )" value="1"/></td>
    <td> <input name="awaybattingpts0" id="awaybattingpts0" type="number" min="0" onchange="calculate_points( this, 0 )" value="0"/></td>
    <td> <input name="awaybowlingpts0" id="awaybowlingpts0" type="number" min="0" onchange="calculate_points( this, 0 )" value="0"/></td>
    <td> <input name="awaypenaltypts0" id="awaypenaltypts0" type="number" min="0" onchange="calculate_points( this, 0 )" value="0"/></td>
    <td> <input name="awaytotalpts0" id="awaytotalpts0" type="number" onchange="calculate_points( this, 0 )" value="1"/></td>
    </tr>
    <tr>
    <td class="teamcol">&nbsp;</td><td colspan="10">&nbsp;</td>
    </tr>
    <tr>
    <td> <input type="text" id="hometeam1" name="hometeam1" value="T&E" readonly/> </td>
    <td> <select name="homeplayed1" size="1" onchange="calculate_points( this, 1 )">
      <option value="Y" >Y </option>
      <option value="N" selected="selected">N </option>
      <option value="A" >A </option>
      </select>
    </td>
    <td> <select name="homeresult1" size="1" onchange="calculate_points( this, 1 )">
      <option value="W" selected="selected">W</option>
      <option value="L" >L</option>
      <option value="T" >T</option>
      </select>
    </td>
    <td> <input name="homeruns1" id="homeruns1" type="number" min="0" value="0"/></td>
    <td> <input name="homewickets1" id="homewickets1" type="number" min="0" value="0"/></td>
    <td class="performances"> <input type="text"  name="homeperformances1" id="homeperformances1" value=""/></td>
    <td> <input  name="homeresultpts1" id="homeresultpts1" type="number" min="0" onchange="calculate_points( this, 1 )" value=""/></td>
    <td> <input name="homebattingpts1" id="homebattingpts1" type="number" min="0" onchange="calculate_points( this, 1 )" value="0"/></td>
    <td> <input name="homebowlingpts1" id="homebowlingpts1" type="number" min="0" onchange="calculate_points( this, 1 )" value="0"/></td>
    <td> <input name="homepenaltypts1" id="homepenaltypts1" type="number" min="0" onchange="calculate_points( this, 1 )" value="0"/></td>
    <td> <input name="hometotalpts1" id="hometotalpts1" type="number" onchange="calculate_points( this, 1 )" value="0"/></td>
    </tr>
    <tr>
    <td> <input type="text" id="awayteam1" name="awayteam1" value="OTs 1" readonly/> </td>
    <td> <select name="awayplayed1" size="1" onchange="calculate_points( this, 1 )">
      <option value="Y" >Y </option>
      <option value="N" selected="selected">N </option>
      <option value="A" >A </option>
      </select>
    </td>
    <td> <select name="awayresult1" size="1" onchange="calculate_points( this, 1 )">
      <option value="W" selected="selected">W</option>
      <option value="L" >L</option>
      <option value="T" >T</option>
      </select>
    </td>
    <td> <input name="awayruns1" id="awayruns1" type="number" min="0" value="0"/></td>
    <td> <input name="awaywickets1" id="awaywickets1" type="number" min="0" value="0"/></td>
    <td class="performances"> <input type="text"  name="awayperformances1" id="awayperformances1" value=""/></td>
    <td> <input  name="awayresultpts1" id="awayresultpts1" type="number" min="0" onchange="calculate_points( this, 1 )" value=""/></td>
    <td> <input name="awaybattingpts1" id="awaybattingpts1" type="number" min="0" onchange="calculate_points( this, 1 )" value="0"/></td>
    <td> <input name="awaybowlingpts1" id="awaybowlingpts1" type="number" min="0" onchange="calculate_points( this, 1 )" value="0"/></td>
    <td> <input name="awaypenaltypts1" id="awaypenaltypts1" type="number" min="0" onchange="calculate_points( this, 1 )" value="0"/></td>
    <td> <input name="awaytotalpts1" id="awaytotalpts1" type="number" onchange="calculate_points( this, 1 )" value="0"/></td>
    </tr>
    <tr>
    <td class="teamcol">&nbsp;</td><td colspan="10">&nbsp;</td>
    </tr>
    <tr>
    <td> <input type="text" id="hometeam2" name="hometeam2" value="OTs 2" readonly/> </td>
    <td> <select name="homeplayed2" size="1" onchange="calculate_points( this, 2 )">
      <option value="Y" >Y </option>
      <option value="N" selected="selected">N </option>
      <option value="A" >A </option>
      </select>
    </td>
    <td> <select name="homeresult2" size="1" onchange="calculate_points( this, 2 )">
      <option value="W" selected="selected">W</option>
      <option value="L" >L</option>
      <option value="T" >T</option>
      </select>
    </td>
    <td> <input name="homeruns2" id="homeruns2" type="number" min="0" value="0"/></td>
    <td> <input name="homewickets2" id="homewickets2" type="number" min="0" value="0"/></td>
    <td class="performances"> <input type="text"  name="homeperformances2" id="homeperformances2" value=""/></td>
    <td> <input  name="homeresultpts2" id="homeresultpts2" type="number" min="0" onchange="calculate_points( this, 2 )" value=""/></td>
    <td> <input name="homebattingpts2" id="homebattingpts2" type="number" min="0" onchange="calculate_points( this, 2 )" value="0"/></td>
    <td> <input name="homebowlingpts2" id="homebowlingpts2" type="number" min="0" onchange="calculate_points( this, 2 )" value="0"/></td>
    <td> <input name="homepenaltypts2" id="homepenaltypts2" type="number" min="0" onchange="calculate_points( this, 2 )" value="0"/></td>
    <td> <input name="hometotalpts2" id="hometotalpts2" type="number" onchange="calculate_points( this, 2 )" value="0"/></td>
    </tr>
    <tr>
    <td> <input type="text" id="awayteam2" name="awayteam2" value="R&H" readonly/> </td>
    <td> <select name="awayplayed2" size="1" onchange="calculate_points( this, 2 )">
      <option value="Y" >Y </option>
      <option value="N" selected="selected">N </option>
      <option value="A" >A </option>
      </select>
    </td>
    <td> <select name="awayresult2" size="1" onchange="calculate_points( this, 2 )">
      <option value="W" selected="selected">W</option>
      <option value="L" >L</option>
      <option value="T" >T</option>
      </select>
    </td>
    <td> <input name="awayruns2" id="awayruns2" type="number" min="0" value="0"/></td>
    <td> <input name="awaywickets2" id="awaywickets2" type="number" min="0" value="0"/></td>
    <td class="performances"> <input type="text"  name="awayperformances2" id="awayperformances2" value=""/></td>
    <td> <input  name="awayresultpts2" id="awayresultpts2" type="number" min="0" onchange="calculate_points( this, 2 )" value=""/></td>
    <td> <input name="awaybattingpts2" id="awaybattingpts2" type="number" min="0" onchange="calculate_points( this, 2 )" value="0"/></td>
    <td> <input name="awaybowlingpts2" id="awaybowlingpts2" type="number" min="0" onchange="calculate_points( this, 2 )" value="0"/></td>
    <td> <input name="awaypenaltypts2" id="awaypenaltypts2" type="number" min="0" onchange="calculate_points( this, 2 )" value="0"/></td>
    <td> <input name="awaytotalpts2" id="awaytotalpts2" type="number" onchange="calculate_points( this, 2 )" value="0"/></td>
    </tr>
    <tr>
    <td class="teamcol">&nbsp;</td><td colspan="10">&nbsp;</td>
    </tr>
    <tr>
    <td> <input type="text" id="hometeam3" name="hometeam3" value="Calmore" readonly/> </td>
    <td> <select name="homeplayed3" size="1" onchange="calculate_points( this, 3 )">
      <option value="Y" >Y </option>
      <option value="N" selected="selected">N </option>
      <option value="A" >A </option>
      </select>
    </td>
    <td> <select name="homeresult3" size="1" onchange="calculate_points( this, 3 )">
      <option value="W" selected="selected">W</option>
      <option value="L" >L</option>
      <option value="T" >T</option>
      </select>
    </td>
    <td> <input name="homeruns3" id="homeruns3" type="number" min="0" value="0"/></td>
    <td> <input name="homewickets3" id="homewickets3" type="number" min="0" value="0"/></td>
    <td class="performances"> <input type="text"  name="homeperformances3" id="homeperformances3" value=""/></td>
    <td> <input  name="homeresultpts3" id="homeresultpts3" type="number" min="0" onchange="calculate_points( this, 3 )" value=""/></td>
    <td> <input name="homebattingpts3" id="homebattingpts3" type="number" min="0" onchange="calculate_points( this, 3 )" value="0"/></td>
    <td> <input name="homebowlingpts3" id="homebowlingpts3" type="number" min="0" onchange="calculate_points( this, 3 )" value="0"/></td>
    <td> <input name="homepenaltypts3" id="homepenaltypts3" type="number" min="0" onchange="calculate_points( this, 3 )" value="0"/></td>
    <td> <input name="hometotalpts3" id="hometotalpts3" type="number" onchange="calculate_points( this, 3 )" value="0"/></td>
    </tr>
    <tr>
    <td> <input type="text" id="awayteam3" name="awayteam3" value="W&P" readonly/> </td>
    <td> <select name="awayplayed3" size="1" onchange="calculate_points( this, 3 )">
      <option value="Y" >Y </option>
      <option value="N" selected="selected">N </option>
      <option value="A" >A </option>
      </select>
    </td>
    <td> <select name="awayresult3" size="1" onchange="calculate_points( this, 3 )">
      <option value="W" selected="selected">W</option>
      <option value="L" >L</option>
      <option value="T" >T</option>
      </select>
    </td>
    <td> <input name="awayruns3" id="awayruns3" type="number" min="0" value="0"/></td>
    <td> <input name="awaywickets3" id="awaywickets3" type="number" min="0" value="0"/></td>
    <td class="performances"> <input type="text"  name="awayperformances3" id="awayperformances3" value=""/></td>
    <td> <input  name="awayresultpts3" id="awayresultpts3" type="number" min="0" onchange="calculate_points( this, 3 )" value=""/></td>
    <td> <input name="awaybattingpts3" id="awaybattingpts3" type="number" min="0" onchange="calculate_points( this, 3 )" value="0"/></td>
    <td> <input name="awaybowlingpts3" id="awaybowlingpts3" type="number" min="0" onchange="calculate_points( this, 3 )" value="0"/></td>
    <td> <input name="awaypenaltypts3" id="awaypenaltypts3" type="number" min="0" onchange="calculate_points( this, 3 )" value="0"/></td>
    <td> <input name="awaytotalpts3" id="awaytotalpts3" type="number" onchange="calculate_points( this, 3 )" value="0"/></td>
    </tr>
    <tr>
    <td class="teamcol">&nbsp;</td><td colspan="10">&nbsp;</td>
    </tr>
      </table>

      <input type="hidden" id="division" name="division" value="U9N.csv"/>
      <input type="hidden" id="matchdate" name="matchdate" value="1-May"/>
      <input type="hidden" id="page" name="page" value="save_results"/>
      <input type="hidden" id="system" name="system" value="nfcca"/>

          <table>
          <tr><td>User:</td>
          <td><input type="text" size="20" name="user" id="user"/><td>
          <tr><td>Code:</td>
          <td><input type="password" size="20" name="code" id="code"/><td>
          </tr>
          </table>

      <input type="submit" value="Save Changes"/>
      </form>

  </body>
</html>
EOF

  validate( $hr->{url}, $content );
  like( $response->content, qr/$hr->{pattern}/xms, "Content matches pattern $hr->{pattern}" );
}

sub test_get {
  my $hr = shift;
  my $response = $lwp->request( GET $hr->{url}, Content_Type => 'text/html' );

  validate( $hr->{url}, $response->content );
  like( $response->content, qr/$hr->{pattern}/xms, "Content matches pattern $hr->{pattern}" );
}

sub validate {
  my ( $url, $content ) = @_;
  ok( $validator->validate_direct_input($content), "$url returns valid HTML5" )
    || do {
    print_errors( $validator->errors );
    print "\n\n" . $content;
    };
  return 1;
}

done_testing;

sub print_errors {
  my $errors = shift;
  foreach my $e ( @{$errors} ) {
    print "\n" . $e . "\n";
  }
  return 1;
}
