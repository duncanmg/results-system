use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Test::Differences;

{

  package Conf;

  sub new {
    return bless {};
  }

  sub get_path   { return "../../../results_system/fixtures/nfcca"; }
  sub get_season { return 2016 }
  sub get_system { return "nfcca" }
}

{

  package Logger;

  sub new {
    return bless {};
  }
  sub debug { return 1; }
  sub info  { return 1; }
  sub error { print STDERR $_[1] . "\n"; return 1; }
}

use_ok('ResultsSystem::Model::WeekData::Reader');

my $wd;
ok(
  $wd = ResultsSystem::Model::WeekData::Reader->new(
    { -configuration => Conf->new(), -logger => Logger->new() }
  ),
  "Object created"
);

# /tmp/results-system/forks/nfcca/results_system/fixtures/nfcca/2016/U9S_14-May.dat

ok( $wd->set_week('14-May'), "set_week" );

ok( $wd->set_division('U9S.csv'), "set_division" );

ok( $wd->read_file(), "read_file" );

eq_or_diff( $wd->get_lines, get_expected(), "get_lines" );

done_testing;

sub get_expected {
  return [
    { 'wickets'       => '7',
      'pitchmks'      => '0',
      'bowlingpts'    => '0',
      'totalpts'      => '12',
      'played'        => 'Y',
      'facilitiesmks' => '0',
      'result'        => 'L',
      'performances'  => 'xxxx',
      'battingpts'    => '0',
      'team'          => 'Fawley',
      'resultpts'     => '12',
      'groundmks'     => '0',
      'runs'          => '100',
      'penaltypts'    => '0'
    },
    { 'runs'          => '200',
      'penaltypts'    => '0',
      'resultpts'     => '15',
      'team'          => 'Langley Manor 1',
      'groundmks'     => '0',
      'battingpts'    => '0',
      'played'        => 'Y',
      'facilitiesmks' => '0',
      'result'        => 'W',
      'performances'  => 'xxxx',
      'totalpts'      => '15',
      'bowlingpts'    => '0',
      'pitchmks'      => '0',
      'wickets'       => '5'
    },
    { 'totalpts'      => '0',
      'pitchmks'      => '0',
      'wickets'       => '0',
      'bowlingpts'    => '0',
      'battingpts'    => '0',
      'played'        => 'N',
      'facilitiesmks' => '0',
      'performances'  => '',
      'result'        => 'W',
      'runs'          => '0',
      'penaltypts'    => '0',
      'team'          => 'Bashley',
      'resultpts'     => '0',
      'groundmks'     => '0'
    },
    { 'pitchmks'      => '0',
      'wickets'       => '0',
      'bowlingpts'    => '0',
      'totalpts'      => '0',
      'played'        => 'N',
      'facilitiesmks' => '0',
      'performances'  => '',
      'result'        => 'W',
      'battingpts'    => '0',
      'team'          => 'Lymington 2',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'runs'          => '0',
      'penaltypts'    => '0'
    },
    { 'wickets'       => '0',
      'pitchmks'      => '0',
      'bowlingpts'    => '0',
      'totalpts'      => '0',
      'played'        => 'N',
      'facilitiesmks' => '0',
      'performances'  => '',
      'result'        => 'W',
      'battingpts'    => '0',
      'team'          => 'New Milton',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'runs'          => '0',
      'penaltypts'    => '0'
    },
    { 'battingpts'    => '0',
      'facilitiesmks' => '0',
      'played'        => 'N',
      'result'        => 'W',
      'performances'  => '',
      'totalpts'      => '0',
      'pitchmks'      => '0',
      'bowlingpts'    => '0',
      'wickets'       => '0',
      'runs'          => '0',
      'penaltypts'    => '0',
      'resultpts'     => '0',
      'team'          => 'Hythe & Dibden',
      'groundmks'     => '0'
    },
    { 'runs'          => '0',
      'penaltypts'    => '0',
      'resultpts'     => '0',
      'team'          => 'Lymington 1',
      'groundmks'     => '0',
      'battingpts'    => '0',
      'facilitiesmks' => '0',
      'played'        => 'N',
      'performances'  => '',
      'result'        => 'W',
      'totalpts'      => '0',
      'pitchmks'      => '0',
      'wickets'       => '0',
      'bowlingpts'    => '0'
    },
    { 'pitchmks'      => '0',
      'bowlingpts'    => '0',
      'wickets'       => '0',
      'totalpts'      => '0',
      'played'        => 'N',
      'facilitiesmks' => '0',
      'performances'  => '',
      'result'        => 'W',
      'battingpts'    => '0',
      'resultpts'     => '0',
      'team'          => 'Pylewell Park',
      'groundmks'     => '0',
      'runs'          => '0',
      'penaltypts'    => '0'
    },
    { 'wickets'       => '0',
      'pitchmks'      => '0',
      'bowlingpts'    => '0',
      'totalpts'      => '0',
      'performances'  => '',
      'result'        => 'W',
      'facilitiesmks' => '0',
      'played'        => 'N',
      'battingpts'    => '0',
      'groundmks'     => '0',
      'resultpts'     => '0',
      'team'          => '',
      'penaltypts'    => '0',
      'runs'          => '0'
    },
    { 'result'        => 'W',
      'performances'  => '',
      'played'        => 'N',
      'facilitiesmks' => '0',
      'battingpts'    => '0',
      'wickets'       => '0',
      'pitchmks'      => '0',
      'bowlingpts'    => '0',
      'totalpts'      => '0',
      'groundmks'     => '0',
      'resultpts'     => '0',
      'team'          => '',
      'penaltypts'    => '0',
      'runs'          => '0'
    },
    { 'pitchmks'      => '0',
      'wickets'       => '0',
      'bowlingpts'    => '0',
      'totalpts'      => '0',
      'played'        => 'N',
      'facilitiesmks' => '0',
      'result'        => 'W',
      'performances'  => '',
      'battingpts'    => '0',
      'resultpts'     => '0',
      'team'          => '',
      'groundmks'     => '0',
      'runs'          => '0',
      'penaltypts'    => '0'
    },
    { 'runs'          => '0',
      'penaltypts'    => '0',
      'resultpts'     => '0',
      'team'          => '',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'pitchmks'      => '0',
      'bowlingpts'    => '0',
      'wickets'       => '0',
      'battingpts'    => '0',
      'played'        => 'N',
      'facilitiesmks' => '0',
      'result'        => 'W',
      'performances'  => ''
    },
    { 'totalpts'      => '0',
      'pitchmks'      => '0',
      'bowlingpts'    => '0',
      'wickets'       => '0',
      'battingpts'    => '0',
      'played'        => 'N',
      'facilitiesmks' => '0',
      'result'        => 'W',
      'performances'  => '',
      'runs'          => '0',
      'penaltypts'    => '0',
      'team'          => '',
      'resultpts'     => '0',
      'groundmks'     => '0'
    },
    { 'groundmks'     => '0',
      'resultpts'     => '0',
      'team'          => '',
      'penaltypts'    => '0',
      'runs'          => '0',
      'bowlingpts'    => '0',
      'pitchmks'      => '0',
      'wickets'       => '0',
      'totalpts'      => '0',
      'performances'  => '',
      'result'        => 'W',
      'facilitiesmks' => '0',
      'played'        => 'N',
      'battingpts'    => '0'
    },
    { 'pitchmks'      => '0',
      'wickets'       => '0',
      'bowlingpts'    => '0',
      'totalpts'      => '0',
      'facilitiesmks' => '0',
      'played'        => 'N',
      'performances'  => '',
      'result'        => 'W',
      'battingpts'    => '0',
      'team'          => '',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'runs'          => '0',
      'penaltypts'    => '0'
    },
    { 'groundmks'     => '0',
      'resultpts'     => '0',
      'team'          => '',
      'penaltypts'    => '0',
      'runs'          => '0',
      'result'        => 'W',
      'performances'  => '',
      'played'        => 'N',
      'facilitiesmks' => '0',
      'battingpts'    => '0',
      'bowlingpts'    => '0',
      'pitchmks'      => '0',
      'wickets'       => '0',
      'totalpts'      => '0'
    },
    { 'totalpts'      => '0',
      'bowlingpts'    => '0',
      'pitchmks'      => '0',
      'wickets'       => '0',
      'battingpts'    => '0',
      'result'        => 'W',
      'performances'  => '',
      'facilitiesmks' => '0',
      'played'        => 'N',
      'penaltypts'    => '0',
      'runs'          => '0',
      'groundmks'     => '0',
      'team'          => '',
      'resultpts'     => '0'
    },
    { 'resultpts'     => '0',
      'team'          => '',
      'groundmks'     => '0',
      'runs'          => '0',
      'penaltypts'    => '0',
      'bowlingpts'    => '0',
      'pitchmks'      => '0',
      'wickets'       => '0',
      'totalpts'      => '0',
      'played'        => 'N',
      'facilitiesmks' => '0',
      'performances'  => '',
      'result'        => 'W',
      'battingpts'    => '0'
    },
    { 'battingpts'    => '0',
      'result'        => 'W',
      'performances'  => '',
      'facilitiesmks' => '0',
      'played'        => 'N',
      'totalpts'      => '0',
      'pitchmks'      => '0',
      'wickets'       => '0',
      'bowlingpts'    => '0',
      'penaltypts'    => '0',
      'runs'          => '0',
      'groundmks'     => '0',
      'team'          => '',
      'resultpts'     => '0'
    },
    { 'penaltypts'    => '0',
      'runs'          => '0',
      'groundmks'     => '0',
      'team'          => '',
      'resultpts'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'pitchmks'      => '0',
      'bowlingpts'    => '0',
      'battingpts'    => '0',
      'performances'  => '',
      'result'        => 'W',
      'played'        => 'N',
      'facilitiesmks' => '0'
    }
  ];
}

