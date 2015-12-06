use strict;
use warnings;
use Test::More;
use Data::Dumper;
use Test::Differences;

use_ok('FormValidator');

my $fv = FormValidator->new();
isa_ok( $fv, 'FormValidator' );

is( ref( $fv->substitute("email") ),         "ARRAY", "Simple 'email'" );
is( scalar( @{ $fv->substitute("email") } ), 1,       "Simple 'email' 2" );
is( ref( $fv->substitute("email")->[0] ),    "CODE",  "Simple 'email' 3" );

ok( $fv->substitute( [ [ "FV_length_between", 1, 10 ] ] ),
    "More complex example" );

my $r = $fv->substitute_constraints( { id => "email", t => "email" } );
is( ref($r),            "HASH", "substitute_constraints 1" );
is( scalar( keys %$r ), 2,      "substitute_constraints 1" );
ok( $r->{id} && $r->{t}, "Keys ok" );

my $results = $fv->check( { id => 'duncan.garland@ntlworld.com' },
    { required => ['id'], constraint_methods => { id => 'email' } } );
ok( $results->success, "email validated" );

$results = $fv->check( { id => 'duncan.garlandntlworld.com' },
    { required => ['id'], constraint_methods => { id => 'email' } } );
ok( !$results->success, "email not validated" );

$results = $fv->check( { id => 'duncan' },
    { required => ['id'], constraint_methods => { id => [["FV_length_between", 1, 10 ]] } } );
ok( $results->success, "FV_length_between validated" );

$results = $fv->check( { id => 'X' x 11 },
    { required => ['id'], constraint_methods => { id => [["FV_length_between", 1, 10 ]] } } );
ok( !$results->success, "FV_length_between validated" );

done_testing;

