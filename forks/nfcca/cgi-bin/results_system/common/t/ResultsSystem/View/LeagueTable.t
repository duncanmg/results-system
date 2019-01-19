use strict;
use warnings;
use Test::More;
use Test::Exception;
use Test::Deep;
use Test::Differences;
use DateTime::Tiny;
use Data::Dumper;
use Clone qw/clone/;

use_ok('ResultsSystem::View::LeagueTable');
use_ok('ResultsSystem');

my $now = DateTime::Tiny->now() . '';

my ( $rs, $f, $lt );

ok( $rs = ResultsSystem->new, "Created object" );
isa_ok( $rs, 'ResultsSystem' );

ok( $rs->get_starter->start('nfcca'), "Started system" );

ok( $f = $rs->get_factory, "Created factory" );
isa_ok( $f, 'ResultsSystem::Factory' );

ok( $lt = $f->get_league_table_view, "Got LeagueTable" );
isa_ok( $lt, 'ResultsSystem::View::LeagueTable' );

my $data = {
  -data => {
    rows => [
      { team         => 'A',
        'played'     => 3,
        'won'        => 2,
        'tied'       => 1,
        'lost'       => 0,
        'battingpts' => 10,
        'bowlingpts' => 5,
        'penaltypts' => 1,
        'totalpts'   => 20,
        'average'    => 20 / 3,
      },
      { team         => 'b',
        'played'     => 4,
        'won'        => 3,
        'tied'       => 1,
        'lost'       => 0,
        'battingpts' => 11,
        'bowlingpts' => 6,
        'penaltypts' => 0,
        'totalpts'   => 15,
        'average'    => 15 / 4,
      },
    ],
    division  => 'U9N.csv',
    timestamp => $now,
  }
};

my $expected = <<HTML;
<!DOCTYPE html>
<html lang='en'>
<head>
<meta charset="UTF-8">
<!--***************************************************************
*
*       Copyright Duncan Garland Consulting Ltd 2003-2008. All rights reserved.
*       Copyright Duncan Garland 2008-2018. All rights reserved.
*
****************************************************************-->

<title>Results System</title>
<link rel="stylesheet" type="text/css" href="/results_system/custom/nfcca/nfcca_styles.css" />


<script src="/results_system/common/common.js"></script>

</head>
  <body>
  
<h1>New Forest Colts Cricket Association 2017</h1>
<h2>Division: U9N</h2>
<p><a href="/cgi-bin/results_system/common/results_system.pl?page=tables_index&system=nfcca">Return to Tables Index</a></p>

<table class="league_table">
<tr>
<th class="teamcol">Team</th>
<th>Played</th>
<th>Won</th>
<th>Tied</th>
<th>Lost</th>
<th>Batting Pts</th>
<th>Bowling Pts</th>
<th>Penalty Pts</th>
<th>Total</th>
<th>Average</th>
</tr>
\t<tr>
\t<td class="teamcol">A</td>
\t<td>3</td>
\t<td>2</td>
\t<td>1</td>
\t<td>0</td>
\t<td>10</td>
\t<td>5</td>
\t<td>1</td>
\t<td>20</td>
\t<td>6.66666666666667</td>
\t</tr>
\t<tr>
\t<td class="teamcol">b</td>
\t<td>4</td>
\t<td>3</td>
\t<td>1</td>
\t<td>0</td>
\t<td>11</td>
\t<td>6</td>
\t<td>0</td>
\t<td>15</td>
\t<td>3.75</td>
\t</tr>

</table>
<p class="timestamp">$now</p>

  </body>
</html>
HTML

lives_ok( sub { $lt->run($data); }, 'run method lives' );

eq_or_diff( sprintf( "%s", $lt->create_document($data) ), $expected );

done_testing;
