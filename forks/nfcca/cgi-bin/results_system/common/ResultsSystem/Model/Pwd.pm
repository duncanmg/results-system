# *************************************************************
#
# Name: Pwd.pm
#
# 0.1  - 25 Jun 08 - POD added.
#
# *************************************************************

{

  package ResultsSystem::Model::Pwd;

  use strict;
  use warnings;

  use Time::localtime;
  use Slurp;
  use Data::Dumper;

  use parent qw/ ResultsSystem::Model/;

=head1 Pwd

Object which facilitates password handling.

=cut

=head2 External Methods

=cut

=head3 new

Constructor for the Pwd object. Accepts -config and -query arguments.

=cut

  #***************************************
  sub new {

    #***************************************
    my ( $class, $args ) = @_;
    my $self = {};
    bless $self, $class;
    my %args = %$args;

    if ( $args{-configuration} ) {
      $self->set_configuration( $args{-configuration} );
      $self->set_pwd_dir( $self->get_configuration->get_path( -log_dir => "Y" ) );
    }

    $self->set_wrong_file("wrong");
    $self->_set_vwrong_file("vwrong");

    $self->logger->debug("Pwd object created.") if $self->logger;

    return $self;
  }

=head3 check_pwd

This method interrogates the query object and retrieves the user and code parameters.
It then reads the correct password for the user from the ResultsConfiguration object.

It returns an error code (0 for success) and a message.

 ( $err, $msg ) = $p->check_pwd();
 if ( $err != 0 ) {
   print $msg . "\n";
 }  

=cut

  #***************************************
  sub check_pwd {

    #***************************************
    my $self = shift;
    my $err  = 1;
    my $q    = $self->get_query;
    my $c    = $self->get_configuration;

    my $msg;

    my $user = $q->param("user");
    my $code = $q->param("code");
    my $real = $c->get_code($user);
    if ( !$real ) {
      $self->logger->debug("No password for user $user.");
      $err = 1;
    }
    else {
      ( $err, $msg ) = $self->check_code( $real, $code, $user );
    }

    return ( $err, $msg );

  }

=head3 set_pwd_dir

=cut

  #*****************************************************************************
  sub set_pwd_dir {

    #*****************************************************************************
    my $self = shift;
    $self->{PWDDIR} = shift;
  }

=head2 Internal Methods

=cut

=head3 check_code

Accepts two alphanumeric strings and the name of the user. It compares the 2 strings and
if they do not match, it returns 1, otherwise it returns 0.

It records the number of incorrect tries per team in a file.
If more than three incorrect tries have been made, and the current attempt is invalid,
it issues a "Too Many Tries" message. No further attempts will be validated that day.

There is also the concept of the password being wrong or very wrong.

($err, $msg) = $self->check_code($correct_pwd, $pwd_entered_by_user, $user);

=cut

  #*****************************************************************************
  sub check_code

    #*****************************************************************************
  {
    my ( $self, $real_pwd, $user_pwd, $teamfile ) = @_;
    my $err = 0;
    my $msg;

    $real_pwd =~ s/\W//g;
    $user_pwd =~ s/\W//g;
    $teamfile =~ s/\W//g;

    if ( $real_pwd eq undef || $user_pwd eq undef || $teamfile eq undef ) {
      $self->logger->debug(
        "One or more arguments is undefined." . Dumper( $real_pwd, $user_pwd, $teamfile ) );
      return ( 1, "<h3>You have entered an incorrect password.</h3>" );
    }

    ( $err, $msg ) = $self->_too_many_tries( $self->_get_wrong_file(), $teamfile, 3 );
    return ( $err, $msg ) if $err;

    ( $err, $msg ) = $self->check_very_wrong( $real_pwd, $user_pwd, $teamfile );
    $self->logger->debug( $err . " returned by check_very_wrong()" );
    return ( $err, $msg ) if $err;

    if ( $user_pwd ne $real_pwd ) {

      $self->logger->debug("Incorrect password");
      $msg = "<h3>You have entered an incorrect password.</h3>";
      $err = 1;

      #Log incorrect try in file.
      $self->_write_tries( $self->_get_wrong_file(), $teamfile );

    }    #pwd

    $self->logger->debug( "Leaving check_code(): " . $err );
    return ( $err, $msg );
  }    # End check_code()

=head3 check_very_wrong

Accepts two alphanumeric strings and the name of the user. It compare the 2 strings, and
if at least 3 characters are correct, it returns 0, otherwise it returns 1.

It records the number of incorrect tries per team in the file $self->{VWRONGFILE}.
If more than three incorrect tries have been made, and the current attempt is invalid,
it issues a "Too Many Tries" message.

=cut

  #*****************************************************************************
  sub check_very_wrong

    #*****************************************************************************
  {
    my ( $self, $real_pwd, $user_pwd, $teamfile ) = @_;

    my $vwrong = 0;
    my $err    = 0;
    my $x      = 0;
    my $msg    = "<h3>You have entered an incorrect password.</h3>";
    my $count  = 0;
    $self->logger->debug("In check_very_wrong()");

    foreach my $p ( ( $teamfile, $real_pwd, $user_pwd ) ) {
      if ( !defined $p ) {
        $self->logger->error( "One or more parameters is undefined. "
            . Dumper( ( $teamfile, $real_pwd, $user_pwd ) ) );
        return ( 1, $msg );
      }
    }

    # If password is right then no need to do anything. Test as strings.
    return ( 0, undef ) if ( $real_pwd eq $user_pwd );

    if ( length($real_pwd) < 3 ) {
      $self->logger->debug( "Do not check short code. " . length($real_pwd) < 3 );
      return ( 0, undef );
    }

    my $vwrong_msg;
    ( $err, $vwrong_msg ) = $self->_too_many_tries( $self->_get_vwrong_file(), $teamfile, 3 );
    return ( $err, $vwrong_msg ) if $err;

    #Compare each digit in turn. (Compare as characters.)
    #At least three must be correct.
    $count = $self->_compare_characters( $real_pwd, $user_pwd );
    return ( 0, undef ) if $count >= 3;

    $self->_write_tries( $self->_get_vwrong_file(), $teamfile );
    $self->logger->debug("Incorrect password (Very wrong)");

    return ( 1, $msg );

  }    # End check_very_wrong()

=head3 _too_many_tries

Loop through file, if it exists, and count the incorrect tries.

=cut

  sub _too_many_tries {
    my ( $self, $file, $string, $max_tries ) = @_;
    my $err = $self->_count_tries( $file, $string, $max_tries );
    if ($err) {
      $self->logger->error("Too many incorrect tries $file, $string");
      return ( $err,
        "<h3>You have entered an incorrect password too many times in one day.</h3>" );

    }
    return ( $err, undef );
  }

=head3 _count_tries

Returns true if the number of occurrences of string in file is greater than or equal to
max_tries.

Returns false if the file is missing or contains less occurrences than max_tries.

=cut

  #*****************************************************************************
  sub _count_tries {

    #*****************************************************************************
    my ( $self, $file, $string, $max_tries ) = @_;
    my $err = 0;
    my @lines;
    $self->logger->debug("file=$file string=$string max_tries=$max_tries");

    if ( -f $file ) {
      @lines = slurp($file);
    }
    my $count = grep /^$string$/, @lines;
    if ( $count >= $max_tries ) {
      $err = 1;
    }
    return $err;
  }

=head3 _write_tries

=cut

  #*****************************************************************************
  sub _write_tries {

    #*****************************************************************************
    my $self   = shift;
    my $file   = shift;
    my $string = shift;
    my $err    = 0;
    my $FP;
    if ( !open( $FP, ">>", $file ) ) {
      $self->logger->error("Unable to open $file or writing.");
      $err = 1;
    }
    else {
      print $FP $string . "\n";
      close $FP;
    }
    return $err;
  }

=head3 _compare_characters

$count = $self->_compare_characters($s1, $s2);

Returns the number of characters in s1 which are in the same position in s2.

=cut

  #*****************************************************************************
  sub _compare_characters {

    #*****************************************************************************
    my $self  = shift;
    my $s1    = shift;
    my $s2    = shift;
    my $count = 0;

    for ( my $x = 0; $x < length($s1); $x++ ) {

      if ( substr( $s1, $x, 1 ) eq substr( $s2, $x, 1 ) ) {
        $count++;
      }

    }

    return $count;

  }

=head3 _get_suffix

Returns the day of the year and a 3 digit string pre-filled with zeroes.
eg '035'

=cut

  sub _get_suffix {
    my $self = shift;
    my $lt   = localtime();

    my $suffix = $lt->yday;
    while ( length $suffix < 3 ) { $suffix = '0' . $suffix; }
    return $suffix;
  }

=head3 _get_wrong_file

Returns the full filename of the wrong file.

=cut

  #*****************************************************************************
  sub _get_wrong_file {

    #*****************************************************************************
    my $self = shift;
    return $self->get_pwd_dir . '/' . $self->{WRONGFILE};
  }

=head3 _get_vwrong_file

Returns the full filename of the very wrong file.

=cut

  #*****************************************************************************
  sub _get_vwrong_file {

    #*****************************************************************************
    my $self = shift;
    return $self->get_pwd_dir . '/' . $self->{VWRONGFILE};
  }

=head3 _set_vwrong_file

Sets the name of the wrong file. No path.

=cut

  #*****************************************************************************
  sub _set_vwrong_file {

    #*****************************************************************************
    my $self = shift;
    my $stem = shift;
    if ($stem) {
      my $s  = $self->_get_suffix;
      my $vw = $stem . $s . ".log";
      $self->{VWRONGFILE} = $vw;
    }
  }

=head3 set_wrong_file

Sets the name of the very wrong file. No path.

=cut

  #*****************************************************************************
  sub set_wrong_file {

    #*****************************************************************************
    my $self = shift;
    my $stem = shift;
    if ($stem) {
      my $s  = $self->_get_suffix;
      my $vw = $stem . $s . ".log";
      $self->{WRONGFILE} = $vw;
    }
  }

=head3 get_pwd_dir

Returns the directory which contains the wrong file and the very wrong file.

=cut

  #*****************************************************************************
  sub get_pwd_dir {

    #*****************************************************************************
    my $self = shift;
    return $self->{PWDDIR};
  }

  1;
}