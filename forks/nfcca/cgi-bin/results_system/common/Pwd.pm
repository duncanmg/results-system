# *************************************************************
#
# Name: Pwd.pm
#
# 0.1  - 25 Jun 08 - POD added.
#
# *************************************************************

{

  package Pwd;

  use strict;
  use CGI;

  use Parent;
  use Time::localtime;
  use Slurp;
  use Data::Dumper;

  our @ISA = qw/Parent/;

=head1 Pwd

Object which facilitates password handling. Inherits from Parent.pm and uses
the password methods of the Fcutils2 object.

=cut

=head2 External Methods

=cut

=head3 new

Constructor for the Pwd object. Accepts -config and -query arguments.

=cut

  #***************************************
  sub new {

    #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    $self->initialise( \%args );

    $self->set_pwd_dir( $self->get_configuration->get_path( -log_dir => "Y" ) );
    $self->set_wrong_file("wrong");
    $self->_set_vwrong_file("vwrong");

    $self->logger->debug("Pwd object created.");

    return $self;
  }

=head3 get_pwd_fields

Reurns the HTML for a table containing 1 row and 2 cells. The first cell
contains the user input field, the second contains the passwords input fields. 

The id and name attributes are the same and are set to "user" and "code" respectively.

=cut

  #***************************************
  sub get_pwd_fields {

    #***************************************
    my $self = shift;
    my $line;
    my $q = $self->get_query;

    $line = $q->td("User:") . "\n";
    $line =
        $line
      . $q->td( $q->input( { -type => "text", -size => 20, -name => "user", -id => "user" } ) )
      . "\n";
    $line = $line . $q->td("Code:") . "\n";
    $line =
      $line
      . $q->td(
      $q->input( { -type => "password", -size => 20, -name => "code", -id => "code" } ) )
      . "\n";
    $line = $q->Tr($line) . "\n";
    $line = $q->table($line) . "\n";

    return $line;
  }

=head3 check_pwd

This method interrogates the query object and retrieves the user and code parameters.
It then reads the correct password for the user from the ResultsConfiguration object.

It uses the check_code method of the Fcutils2 object to compare the two codes.

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

Accepts two 6 digit numbers and the number of a team. It compare the 2 numbers, and
if more than 3 digits are different, it returns 1, otherwise it returns 0.

It records the number of incorrect tries per team in the file $self->{VWRONGFILE}.
If more than three incorrect tries have been made, and the current attempt is invalid,
it issue a "Too Many Tries" message.

=cut

  #*****************************************************************************
  sub check_very_wrong

    #*****************************************************************************
  {
    my ( $self, $real_pwd, $user_pwd, $teamfile ) = @_;

    my $vwrong = 0;
    my $err    = 0;
    my $x      = 0;
    my $msg;
    my $count = 0;
    $self->logger->debug("In check_very_wrong()");

    if ( $teamfile eq undef ) {
      $self->logger->debug("Teamfile is undefined.");
      $vwrong = 1;
    }
    if ( $real_pwd eq undef ) {
      $self->logger->debug("Real pwd is undefined.");
      $vwrong = 1;
    }
    if ( $user_pwd eq undef ) {
      $self->logger->debug("User pwd is undefined.");
      $vwrong = 1;
    }

    if ( !-d $self->get_pwd_dir ) {
      $self->logger->debug(
        "check_very_wrong(): Directory does not exist. " . $self->get_pwd_dir );
      $vwrong = 1;
    }

    # If password is right then no need to do anything. Test as strings.
    if ( ( $real_pwd ne $user_pwd ) || $real_pwd eq undef ) {

      # User entry must be between 3 and 6 alphanumeric characters to be worth considering.
      # if ($user_pwd !~ m/^\w{3,6}$/) {
      #   $self->logger->debug( "User entry too short or too long");
      #   $vwrong = 1;
      # }
      # else {

      #Compare each digit in turn. (Compare as characters.)
      $count = $self->_compare_characters( $real_pwd, $user_pwd );

      #At least three must be correct.
      if ( $count < 3 && length($real_pwd) >= 3 ) { $vwrong = 1; }

      # $self->logger->debug($count . " characters match.", 0);
      # }
    }

    if ( $vwrong == 1 && $err == 0 ) {

      ( $err, $msg ) = $self->_too_many_tries( $self->_get_vwrong_file(), $teamfile, 3 );
      return ( $err, $msg ) if $err;

    }    #err

    if ( $vwrong == 1 && $err == 0 ) {

      $self->_write_tries( $self->_get_vwrong_file(), $teamfile );
      $self->logger->debug("Incorrect password (Very wrong)");
      $msg = "<h3>You have entered an incorrect password.</h3>";
      $err = 1;

    }    #err

    if ( $vwrong == 1 ) {
      $err = 1;
    }

    return ( $err, $msg );

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

=cut

  sub _get_suffix {
    my $self = shift;
    my $lt   = localtime();

    my $suffix = $lt->yday;
    while ( length $suffix < 3 ) { $suffix = '0' . $suffix; }
    return $suffix;
  }

=head3 _get_wrong_file

=cut

  #*****************************************************************************
  sub _get_wrong_file {

    #*****************************************************************************
    my $self = shift;
    return $self->get_pwd_dir . '/' . $self->{WRONGFILE};
  }

=head3 _get_vwrong_file

=cut

  #*****************************************************************************
  sub _get_vwrong_file {

    #*****************************************************************************
    my $self = shift;
    return $self->get_pwd_dir . '/' . $self->{VWRONGFILE};
  }

=head3 _set_vwrong_file

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

=cut

  #*****************************************************************************
  sub get_pwd_dir {

    #*****************************************************************************
    my $self = shift;
    return $self->{PWDDIR};
  }

  1;
}
