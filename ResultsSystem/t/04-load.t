use strict;
use warnings;
use Test::More;
use Test::Exception;
use Cwd qw/cwd/;
use Path::Class;

use_ok('ResultsSystem::IO::XML');

my $f = Path::Class::File->new( cwd(), "t", "test.xml" );

my $obj = ResultsSystem::IO::XML->new( full_filename => $f );
isa_ok( $obj, 'ResultsSystem::IO::XML' );

my $data = { one => 1, two => 2, three => [ 4, 5, 6 , 7 ] };

$obj->_write($data);

done_testing;

