use strict;
use warnings;
use Test::More;
use Test::Exception;
use Cwd qw/cwd/;
use Path::Class;
use Data::Dumper;
use Test::Deep;

use_ok('ResultsSystem::IO::XML');

my $f = Path::Class::File->new( cwd(), "t", "result.xml" );

my $obj = ResultsSystem::IO::XML->new( full_filename => $f );
isa_ok( $obj, 'ResultsSystem::IO::XML' );

my $data = {
  result_set => [
    { 'match' => [
        { 'match_date'   => ['21-Jan-2014'],
          'played'       => ['Y'],
          'away'         => ['Waterlooville'],
          'away_details' => [
            { 'runs_scored'    => ['100'],
              'wickets_lost'   => ['5'],
              'bowling_points' => ['3'],
              'penalty_points' => ['0'],
              'batting_points' => ['5'],
              'result'         => ['W']
            }
          ],
          'home_details' => [
            { 'runs_scored'    => ['100'],
              'wickets_lost'   => ['5'],
              'bowling_points' => ['3'],
              'penalty_points' => ['0'],
              'batting_points' => ['5'],
              'result'         => ['W']
            }
          ],
          'home' => ['Purbrook']
        },
        { 'match_date'   => ['21-Jan-2014'],
          'played'       => ['Y'],
          'away'         => ['P\'mouth & S\'sea'],
          'away_details' => [
            { 'runs_scored'    => ['100'],
              'wickets_lost'   => ['5'],
              'bowling_points' => ['3'],
              'penalty_points' => ['0'],
              'batting_points' => ['5'],
              'result'         => ['W']
            }
          ],
          'home_details' => [
            { 'runs_scored'    => ['100'],
              'wickets_lost'   => ['5'],
              'bowling_points' => ['3'],
              'penalty_points' => ['0'],
              'batting_points' => ['5'],
              'result'         => ['W']
            }
          ],
          'home' => ['Fareham & Crofton']
        }
      ]
    }
  ]
};

#$obj->_write($data);

my $data_read = $obj->_read();
cmp_deeply( $data_read, $data, "The data read from result.xml is as expected." )
  || diag( Dumper $data_read);

$obj = ResultsSystem::IO::XML->new( full_filename => "./t/result_output.xml" );
isa_ok( $obj, 'ResultsSystem::IO::XML' );

ok( $obj->_write($data_read), "Wrote data to file result_output.xml as xml" );

$obj = ResultsSystem::IO::XML->new( full_filename => "./t/result_output.xml" );
isa_ok( $obj, 'ResultsSystem::IO::XML' );

$data_read = $obj->_read();
cmp_deeply( $data_read, $data, "The data read from result.xml is as expected." )
  || diag( Dumper $data_read);

done_testing;

