use strict;
use warnings;
use Test::More;
use Test::Exception;
use Data::Dumper;

use Helper qw/ get_config get_logger/;

sub get_user {
  return 'TESTING' . sprintf( "%06d", int( rand() * 1000000 ) );
}
my $user = get_user();

use_ok('ResultsSystem::Model::Pwd');

my $config = get_config;

my $pwd =
  ResultsSystem::Model::Pwd->new( { -configuration => $config, -logger => get_logger() } );
isa_ok( $pwd, 'ResultsSystem::Model::Pwd' );

$pwd->logger->less_logging(4);    # Disable logging.

my ( $ok, $msg ) = $pwd->check_code( 'banana', 'banana', $user );
ok( $ok, "Code accepted" ) || diag( Dumper( $ok, $msg ) );

( $ok, $msg ) = $pwd->check_code( 'banana', 'banana2', $user );
ok( !$ok, "Code rejected" ) || diag( Dumper( $ok, $msg ) );
is( $msg, '<h3>You have entered an incorrect password.</h3>', "msg ok" );

( $ok, $msg ) = $pwd->check_code( 'banana2', 'banana', $user );
ok( !$ok, "Code rejected. 2 > 1" ) || diag( Dumper( $ok, $msg ) );
is( $msg, '<h3>You have entered an incorrect password.</h3>', "msg ok" );

( $ok, $msg ) = $pwd->check_code( 'banaNa', 'banana', $user );
ok( !$ok, "Code rejected. Case sensitive" ) || diag( Dumper( $ok, $msg ) );
is( $msg, '<h3>You have entered an incorrect password.</h3>', "msg ok" );

( $ok, $msg ) = $pwd->check_code( undef, 'banana', $user );
ok( !$ok, "Code rejected. First parameter is undef." ) || diag( Dumper( $ok, $msg ) );

( $ok, $msg ) = $pwd->check_code( 'banana', undef, $user );
ok( !$ok, "Code rejected. Second parameter undef" ) || diag( Dumper( $ok, $msg ) );

( $ok, $msg ) = $pwd->check_code( 'banana', 'banana', undef );
ok( !$ok, "Code rejected. User is undef" ) || diag( Dumper( $ok, $msg ) );

( $ok, $msg ) = $pwd->check_code( undef, undef, $user );
ok( !$ok, "Code rejected. First and second parameters undef" ) || diag( Dumper( $ok, $msg ) );

( $ok, $msg ) = $pwd->check_code( undef, undef, undef );
ok( !$ok, "Code rejected. All parameters undef" ) || diag( Dumper( $ok, $msg ) );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$user = get_user();

# Password is only a little wrong.
my $count = 0;
for ( $count = 0; $count < 3; $count++ ) {
  ( $ok, $msg ) = $pwd->check_code( 'banana', 'Banana', $user );
  ok( !$ok, "check_code: Code rejected $count" );
  is( $msg, '<h3>You have entered an incorrect password.</h3>', "msg ok" );
}

( $ok, $msg ) = $pwd->check_code( 'banana', 'Banana', $user );
ok( !$ok, "check_code: Code rejected $count" );
is( $msg, '<h3>You have entered an incorrect password too many times in one day.</h3>',
  "msg ok" );

( $ok, $msg ) = $pwd->check_code( 'banana', 'banana', $user );
ok( !$ok, "check_code: Correct code rejected." );
is( $msg, '<h3>You have entered an incorrect password too many times in one day.</h3>',
  "msg ok" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

$user = get_user();

# Password is very wrong.
( $ok, $msg ) = $pwd->check_very_wrong( 'banana', 'banana', $user );
ok( $ok, "check_very_wrong Code accepted" ) || diag( Dumper( $ok, $msg ) );
is( $msg, undef, "check_very_wrong msg ok" );

$count = 0;
for ( $count = 0; $count < 3; $count++ ) {
  ( $ok, $msg ) = $pwd->check_very_wrong( 'banana', 'apple', $user );
  ok( !$ok, "check_very_wrong Code rejected $count" );
  is( $msg, '<h3>You have entered an incorrect password.</h3>', "check_very_wrong msg ok" );
}

( $ok, $msg ) = $pwd->check_very_wrong( 'banana', 'apple', $user );
ok( !$ok, "check_very_wrong Code rejected $count" );
is( '<h3>You have entered an incorrect password too many times in one day.</h3>',
  $msg, "check_very_wrong msg ok" );

( $ok, $msg ) = $pwd->check_very_wrong( 'banana', 'banana', $user );
ok( $ok, "Correct code is accepted." );
is( undef, $msg, "check_very_wrong msg ok" );

# +++++++++++++++++++++++++++++++++++++++++++++++++

is( $pwd->_compare_characters( '1234', '1234' ), 4, "All characters the same." );

is( $pwd->_compare_characters( '1234', '1224' ), 3, "All characters the same except 1." );

is( $pwd->_compare_characters( '1234', 'x23x' ), 2, "All characters the same except 2." );

is( $pwd->_compare_characters( '1234', '123455555' ),
  4, "All characters the same. Stops at end of string 1" );

done_testing;
