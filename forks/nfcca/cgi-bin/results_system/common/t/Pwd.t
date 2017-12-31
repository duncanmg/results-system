use strict;
use warnings;
use Test::More;
use Test::Exception;
use Data::Dumper;

use Helper qw/ get_config/;

sub get_user {
  return 'TESTING' . sprintf( "%06d", int( rand() * 1000000 ) );
}
my $user = get_user();

use_ok('Pwd');

my $config = get_config;

my $pwd = Pwd->new( -config => $config );
isa_ok( $pwd, 'Pwd' );

my ( $err, $msg ) = $pwd->check_code( 'banana', 'banana', $user );
ok( !$err, "Code accepted" ) || diag( Dumper( $err, $msg ) );

( $err, $msg ) = $pwd->check_code( 'banana', 'banana2', $user );
ok( $err, "Code rejected" ) || diag( Dumper( $err, $msg ) );
is( $msg, '<h3>You have entered an incorrect password.</h3>', "msg ok" );

( $err, $msg ) = $pwd->check_code( 'banana2', 'banana', $user );
ok( $err, "Code rejected. 2 > 1" ) || diag( Dumper( $err, $msg ) );
is( $msg, '<h3>You have entered an incorrect password.</h3>', "msg ok" );

( $err, $msg ) = $pwd->check_code( 'banaNa', 'banana', $user );
ok( $err, "Code rejected. Case sensitive" ) || diag( Dumper( $err, $msg ) );
is( $msg, '<h3>You have entered an incorrect password.</h3>', "msg ok" );

( $err, $msg ) = $pwd->check_code( undef, 'banana', $user );
ok( $err, "Code rejected. First parameter is undef." ) || diag( Dumper( $err, $msg ) );

( $err, $msg ) = $pwd->check_code( 'banana', undef, $user );
ok( $err, "Code rejected. Second parameter undef" ) || diag( Dumper( $err, $msg ) );

( $err, $msg ) = $pwd->check_code( 'banana', 'banana', undef );
ok( $err, "Code rejected. User is undef" ) || diag( Dumper( $err, $msg ) );

( $err, $msg ) = $pwd->check_code( undef, undef, $user );
ok( $err, "Code rejected. First and second parameters undef" ) || diag( Dumper( $err, $msg ) );

( $err, $msg ) = $pwd->check_code( undef, undef, undef );
ok( $err, "Code rejected. All parameters undef" ) || diag( Dumper( $err, $msg ) );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$user = get_user();

# Password is only a little wrong.
my $count = 0;
for ( $count = 0; $count < 3; $count++ ) {
  ( $err, $msg ) = $pwd->check_code( 'banana', 'Banana', $user );
  ok( $err, "check_code: Code rejected $count" );
  is( $msg, '<h3>You have entered an incorrect password.</h3>', "msg ok" );
}

( $err, $msg ) = $pwd->check_code( 'banana', 'Banana', $user );
ok( $err, "check_code: Code rejected $count" );
is( $msg, '<h3>You have entered an incorrect password too many times in one day.</h3>',
  "msg ok" );

( $err, $msg ) = $pwd->check_code( 'banana', 'banana', $user );
ok( $err, "check_code: Correct code rejected $count" );
is( $msg, '<h3>You have entered an incorrect password too many times in one day.</h3>',
  "msg ok" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$user = get_user();

# Password is a little wrong.
( $err, $msg ) = $pwd->check_very_wrong( 'banana', 'banana', $user );
ok( !$err, "Code accepted" ) || diag( Dumper( $err, $msg ) );
is( $msg, undef, "msg ok" );

$count = 0;
for ( $count = 0; $count < 3; $count++ ) {
  ( $err, $msg ) = $pwd->check_very_wrong( 'banana', 'apple', $user );
  ok( $err, "Code rejected $count" );
  is( $msg, '<h3>You have entered an incorrect password.</h3>', "msg ok" );
}

( $err, $msg ) = $pwd->check_very_wrong( 'banana', 'apple', $user );
ok( $err, "Code rejected $count" );
is( $msg, '<h3>You have entered an incorrect password too many times in one day.</h3>',
  "msg ok" );

( $err, $msg ) = $pwd->check_very_wrong( 'banana', 'banana', $user );
ok( !$err, "Correct code is accepted." );
is( $msg, undef, "msg ok" );

done_testing;
