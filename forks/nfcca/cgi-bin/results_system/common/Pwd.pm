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

It uses the CheckCode method of the Fcutils2 object to compare the two codes.

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
      ( $err, $msg ) = $self->CheckCode( $real, $code, $user );
    }

    return ( $err, $msg );

  }

=head3 get_pwd_dir

=cut

  #*****************************************************************************
  sub get_pwd_dir {

    #*****************************************************************************
    my $self = shift;
    return $self->{PWDDIR};
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

=head3 CheckCode

Accepts two alphanumeric strings and the name of the user. It compares the 2 strings and
if they do not match, it returns 1, otherwise it returns 0.

It records the number of incorrect tries per team in a file.
If more than three incorrect tries have been made, and the current attempt is invalid,
it issues a "Too Many Tries" message. No further attempts will be validated that day.

($err, $msg) = $self->CheckCode($correct_pwd, $pwd_entered_by_user, $user);

=cut

  #*****************************************************************************
  sub CheckCode

    #*****************************************************************************
  {
    my $self = shift;
    my $err  = 0;
    my $msg;
    my $pwdfile;
    my ( $real_pwd, $user_pwd, $teamfile ) = @_;

    $real_pwd =~ s/\W//g;
    $user_pwd =~ s/\W//g;
    $teamfile =~ s/\W//g;

    if ( $real_pwd eq undef || $user_pwd eq undef ) {
      $self->logger->debug("Either real or entered pwd undefined");
      $err = 1;
    }
    if ( $teamfile eq undef ) {
      $self->logger->debug("Teamfile undefined");
      $err = 1;
    }

    if ( $err == 0 ) {
      ( $err, $msg ) = $self->CheckVeryWrong( $real_pwd, $user_pwd, $teamfile );
      $self->logger->debug( $err . " returned by CheckVeryWrong()" );
    }

    if ( $err == 0 ) {

      # Loop through file, if it exists, and count the incorrect tries.
      $pwdfile = $self->get_pwd_dir . "/" . $self->_get_wrong_file;
      my $too_many_tries = $self->_count_tries( $pwdfile, $teamfile, 3 );
      if ($too_many_tries) {
        $self->logger->error("Too many incorrect tries.");
        $msg = "<h3>You have entered an incorrect password too many times in one day.</h3>";
        $err = 1;
      }    #tries
    }    #err

    if ( $err == 0 ) {

      if ( $user_pwd ne $real_pwd ) {

        $self->logger->debug("Incorrect password");
        $msg = "<h3>You have entered an incorrect password.</h3>";
        $err = 1;

        #Log incorrect try in file.
        $self->_write_tries( $pwdfile, $teamfile );

      }    #pwd

    }    #err
    $self->logger->debug( "Leaving CheckCode(): " . $err );
    return ( $err, $msg );
  }    # End CheckCode()

=head3 CheckVeryWrong

Accepts two 6 digit numbers and the number of a team. It compare the 2 numbers, and
if more than 3 digits are different, it returns 1, otherwise it returns 0.

It records the number of incorrect tries per team in the file $self->{VWRONGFILE}.
If more than three incorrect tries have been made, and the current attempt is invalid,
it issue a "Too Many Tries" message.

=cut

  #*****************************************************************************
  sub CheckVeryWrong

    #*****************************************************************************
  {
    my $self = shift;
    my ( $real_pwd, $user_pwd, $teamfile ) = @_;

    my $vwrong = 0;
    my $err    = 0;
    my $x      = 0;
    my $msg;
    my $vwrongfile = $self->get_pwd_dir . "/" . $self->_get_vwrong_file;
    my $count      = 0;
    $self->logger->debug("In CheckVeryWrong()");

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
      $self->logger->debug( "CheckVeryWrong(): Directory does not exist. " . $self->get_pwd_dir );
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

      # Loop through file, if it exists, and count the incorrect tries.
      my $too_many = $self->_count_tries( $vwrongfile, $teamfile, 3 );

      if ( $too_many == 1 ) {
        $self->logger->error("Too many incorrect tries (Very wrong) ");
        $msg = "<h3>You have entered an incorrect password too many times in one day.</h3>";
        $err = 1;
      }    #tries

    }    #err

    if ( $vwrong == 1 && $err == 0 ) {

      $self->_write_tries( $vwrongfile, $teamfile );
      $self->logger->debug("Incorrect password (Very wrong)");
      $msg = "<h3>You have entered an incorrect password.</h3>";
      $err = 1;

    }    #err

    if ( $vwrong == 1 ) {
      $err = 1;
    }

    return ( $err, $msg );

  }    # End CheckVeryWrong()

=head3 _count_tries

=cut

  #*****************************************************************************
  sub _count_tries {

    #*****************************************************************************
    my $self      = shift;
    my $file      = shift;
    my $string    = shift;
    my $max_tries = shift;
    my $err       = 0;
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
    return $self->{WRONGFILE};
  }

=head3 _get_vwrong_file

=cut

  #*****************************************************************************
  sub _get_vwrong_file {

    #*****************************************************************************
    my $self = shift;
    return $self->{VWRONGFILE};
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

  1;
}
