use strict;
use warnings;

use Test::More;
use Test::Differences;
use Test::Exception;

use Data::Dumper;
use Params::Validate qw/:all/;

use_ok('FormValidator');

my $fv = FormValidator->new();
isa_ok( $fv, 'FormValidator' );

# +++++++++++++++++++++++++++++++++++++++++++++++++

is( ref( $fv->substitute( ["email"] ) ), "ARRAY", "Simple 'email'" );
is( scalar( @{ $fv->substitute( ["email"] ) } ), 1, "Simple 'email' 2" );
is( ref( $fv->substitute( ["email"] )->[0] ), "CODE", "Simple 'email' 3" );

ok( $fv->substitute( [ [ "FV_length_between", 1, 10 ] ] ),
    "More complex example" );

throws_ok(
    sub { $fv->substitute( ["idonotexist"] ) },
    qr/idonotexist is a builtin/,
    "Throws exception for non-existent constraint_method"
);

my $r = $fv->substitute_constraints( { id => "email", t => "email" } );
is( ref($r),            "HASH", "substitute_constraints 1" );
is( scalar( keys %$r ), 2,      "substitute_constraints 2" );
ok( $r->{id} && $r->{t}, "Keys ok" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

my $results;

sub check_id_constraints {
    my ( $val, $constraints ) = validate_pos( @_, 1, 1 );

    $results = $fv->check(
        { id => $val },
        {
            required           => ['id'],
            constraint_methods => {
                id => $constraints
            }
        }
    );
    return $results;
}

$results = check_id_constraints( 'duncan.garland@ntlworld.com', 'email' );
ok( $results->success, "email validated" );

$results = check_id_constraints( 'duncan.garlandntlworld.com', 'email' );
ok( !$results->success, "email not validated" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$results = check_id_constraints( 'duncan', [ [ "FV_length_between", 1, 10 ] ] );
ok( $results->success, "FV_length_between validated" );

$results = check_id_constraints( 'X' x 11, [ [ "FV_length_between", 1, 10 ] ] );
ok( !$results->success, "FV_length_between not validated" );

$results = check_id_constraints( 'X' x 5,
    [ [ "FV_length_between", 1, 10 ], [ "FV_max_length", 10 ] ] );
ok( $results->success, "FV_length_between and FV_max_length validated" );

$results = check_id_constraints( 'X' x 5,
    [ [ "FV_length_between", 1, 10 ], [ "FV_max_length", 2 ] ] );
ok( !$results->success,
    "FV_length_between and FV_max_length correctly not validated" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$results = check_id_constraints( 'X' x 11, qr/x/ix );
ok( $results->success, "Regex validation succeeded" );

$results = check_id_constraints( 'X' x 11, qr/y/ix );
ok( !$results->success, "Regex validation correctly failed" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$results = check_id_constraints( 'X' x 11,
    sub { my ( $f, $v ) = @_; ( $v =~ m/x/ix ) } );
ok( $results->success, "Subroutine validation succeeded" );

$results = check_id_constraints( 'X' x 11,
    sub { my ( $f, $v ) = @_; ( $v =~ m/y/ix ) } );
ok( !$results->success, "Subroutine validation correctly failed" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$results = check_id_constraints( 11, 'match_pos_integer' );
ok( $results->success, "match_pos_integer validation succeeded" );

$results = check_id_constraints( -11, 'match_pos_integer' );
ok( !$results->success, "match_pos_integer validation correctly failed" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$results = check_id_constraints( 11, 'match_integer' );
ok( $results->success, "match_integer validation succeeded" );

$results = check_id_constraints( -11, 'match_integer' );
ok( $results->success,
    "match_integer validation succeeded for negative integer" );

$results = check_id_constraints( 2.2, 'match_integer' );
ok( !$results->success, "match_integer validation correctly failed for float" );

$results = check_id_constraints( 'a', 'match_integer' );
ok( !$results->success,
    "match_integer validation correctly failed for string" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$results = check_id_constraints( 11.7, 'match_float' );
ok( $results->success, "match_float validation succeeded" );

$results = check_id_constraints( -11.01, 'match_float' );
ok( $results->success, "match_float validation succeeded for negative float" );

$results = check_id_constraints( 2, 'match_float' );
ok( !$results->success, "match_float validation correctly failed for integer" );

$results = check_id_constraints( 'a', 'match_float' );
ok( !$results->success, "match_float validation correctly failed for string" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$results = check_id_constraints( 11.7, 'match_pos_float' );
ok( $results->success, "match_pos_float validation succeeded" );

$results = check_id_constraints( -11.01, 'match_pos_float' );
ok( !$results->success,
    "match_pos_float validation correctly failed for negative float" );

$results = check_id_constraints( 2, 'match_pos_float' );
ok( !$results->success,
    "match_pos_float validation correctly failed for integer" );

$results = check_id_constraints( 'a', 'match_pos_float' );
ok( !$results->success,
    "match_pos_float validation correctly failed for string" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$results = check_id_constraints( 'ABC123', 'match_alphanumeric' );
ok( $results->success, "match_alphanumeric validation succeeded for ABC123" );

$results = check_id_constraints( 'AbC123', 'match_alphanumeric' );
ok( $results->success,
    "match_alphanumeric validation succeeded for mixed-case AbC123" );

$results =
  check_id_constraints( 'The cat sat on the mat', 'match_alphanumeric' );
ok( !$results->success,
    "match_alphanumeric validation correctly failed for a sentence" );

# +++++++++++++++++++++++++++++++++++++++++++++++++
done_testing;

