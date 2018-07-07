#! /usr/bin/perl

use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Test::Differences;
use Helper qw/ get_config get_factory get_example_results_full_filename/;

use_ok('ResultsSystem::Model::WeekResults::Reader');

my $wd;
ok( $wd = get_factory->get_week_data_reader_model, "Object created" );

# /tmp/results-system/forks/nfcca/results_system/fixtures/nfcca/2016/U9S_14-May.dat

ok( $wd->set_full_filename( get_example_results_full_filename() ), "set_week" );

ok( $wd->read_file(), "read_file" );

eq_or_diff( $wd->get_lines, get_expected(), "get_lines" ) || diag( Dumper( $wd->get_lines ) );

eq_or_diff( $wd->get_line(2), get_expected()->[2], "get_line" );

done_testing;

sub get_expected {
  return [
    { 'performances'  => 'xxxx',
      'played'        => 'Y',
      'resultpts'     => '2',
      'groundmks'     => '0',
      'totalpts'      => '3',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '3',
      'battingpts' => '2',
      'penaltypts' => '4',
      'runs'       => '0',
      'team'       => 'OTs 1',
      'result'     => 'W'
    },
    { 'performances'  => 'ttttt',
      'played'        => 'Y',
      'resultpts'     => '5',
      'groundmks'     => '0',
      'totalpts'      => '10',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '7',
      'battingpts' => '6',
      'penaltypts' => '8',
      'runs'       => '0',
      'team'       => 'Langley Manor 1',
      'result'     => 'L'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => 'Langley Manor 2',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => 'Calmore',
      'result'     => 'L'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => 'R&H',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => 'T&E',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => 'W&P',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => 'OTs 2',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'Y',
      'resultpts'     => '4',
      'groundmks'     => '0',
      'totalpts'      => '4',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => 'Langley Manor 3',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => 'Paultons',
      'result'     => 'L'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => '',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => '',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => '',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => '',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => '',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => '',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => '',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => '',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0
',
      'pitchmks'   => '0',
      'bowlingpts' => '0',
      'battingpts' => '0',
      'penaltypts' => '0',
      'runs'       => '0',
      'team'       => '',
      'result'     => 'W'
    },
    { 'performances'  => '',
      'played'        => 'N',
      'resultpts'     => '0',
      'groundmks'     => '0',
      'totalpts'      => '0',
      'wickets'       => '0',
      'facilitiesmks' => '0',
      'pitchmks'      => '0',
      'bowlingpts'    => '0',
      'battingpts'    => '0',
      'penaltypts'    => '0',
      'runs'          => '0',
      'team'          => '',
      'result'        => 'W'
    }
  ];
}

