  package ResultsSystem::Model::Pwd;

  use strict;
  use warnings;

  use Time::localtime;
  use Slurp;
  use Data::Dumper;
  use Params::Validate qw/:all/;
  use parent qw/ ResultsSystem::Model/;

  my $incorrect_password = "<h3>You have entered an incorrect password.</h3>";
  my $too_many_tries =
    "<h3>You have entered an incorrect password too many times in one day.</h3>";

=head1 NAME

ResultsSystem::Model::Pwd

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

Object which facilitates password handling.

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

=head2 new

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

    $self->set_logger( $args->{-logger} ) if $args->{-logger};

    $self->set_wrong_file("wrong");
    $self->_set_vwrong_file("vwrong");

    $self->logger->debug("Pwd object created.") if $self->logger;

    return $self;
  }

=head2 check_pwd

This method interrogates the query object and retrieves the user and code parameters.
It then reads the correct password for the user from the ResultsConfiguration object.

It returns an error code (1 for success) and a message.

 ( $err, $msg ) = $p->check_pwd();
 if ( ! $err  ) {
   print $msg . "\n";
 }  

=cut

  #***************************************
  sub check_pwd {

    #***************************************
    my $self = shift;
    my (%args) = validate( @_, { -user => { type => SCALAR }, -code => { type => SCALAR } } );
    my $ok = 0;

    my $c = $self->get_configuration;

    my $msg;

    my $real = $c->get_code( $args{-user} );
    if ( !$real ) {
      $self->logger->error("No password for user $args{-user}.");
      return ( 0, $incorrect_password );
    }
    else {
      ( $ok, $msg ) = $self->check_code( $real, $args{-code}, $args{-user} );
    }

    return ( $ok, $msg );

  }

=head2 set_pwd_dir

=cut

  #*****************************************************************************
  sub set_pwd_dir {

    #*****************************************************************************
    my $self = shift;
    $self->{PWDDIR} = shift;
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 check_code

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
    my $ok = 0;
    my $msg;

    foreach my $p ( $real_pwd, $user_pwd, $teamfile ) {
      $p ||= "";
      $p =~ s/\W//g;
      if ( !$p ) {
        $self->logger->error(
          "One or more arguments is undefined." . Dumper( $real_pwd, $user_pwd, $teamfile ) );
        return ( 0, $incorrect_password );
      }
    }

    ( $ok, $msg ) = $self->_too_many_tries( $self->_get_wrong_file(), $teamfile, 3 );
    return ( $ok, $msg ) if !$ok;

    ( $ok, $msg ) = $self->check_very_wrong( $real_pwd, $user_pwd, $teamfile );
    $self->logger->debug( $ok . " returned by check_very_wrong()" );
    return ( $ok, $msg ) if !$ok;

    if ( $user_pwd ne $real_pwd ) {

      $self->logger->error("Incorrect password");
      $msg = $incorrect_password;
      $ok  = 0;

      #Log incorrect try in file.
      $self->_write_tries( $self->_get_wrong_file(), $teamfile );

    }    #pwd

    $self->logger->debug( "Leaving check_code(): " . $ok );
    return ( $ok, $msg );
  }    # End check_code()

=head2 check_very_wrong

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
    my ( $self, $real_pwd, $user_pwd, $teamfile ) =
      validate_pos( @_, 1, { type => SCALAR }, { type => SCALAR }, { type => SCALAR } );

    my $vwrong = 0;
    my $ok     = 0;
    my $x      = 0;
    my $msg    = $incorrect_password;
    my $count  = 0;
    $self->logger->debug("In check_very_wrong()");

    # If password is right then no need to do anything. Test as strings.
    return ( 1, undef ) if ( $real_pwd eq $user_pwd );

    if ( length($real_pwd) < 3 ) {
      $self->logger->debug( "Do not check short code. " . length($real_pwd) < 3 );
      return ( 1, undef );
    }

    my $vwrong_msg;
    ( $ok, $vwrong_msg ) = $self->_too_many_tries( $self->_get_vwrong_file(), $teamfile, 3 );
    return ( $ok, $vwrong_msg ) if !$ok;

    #Compare each digit in turn. (Compare as characters.)
    #At least three must be correct.
    $count = $self->_compare_characters( $real_pwd, $user_pwd );
    return ( 1, undef ) if $count >= 3;

    $self->_write_tries( $self->_get_vwrong_file(), $teamfile );
    $self->logger->error("Incorrect password (Very wrong)");

    return ( 0, $msg );

  }    # End check_very_wrong()

=head2 _too_many_tries

Loop through file, if it exists, and count the incorrect tries.

=cut

  sub _too_many_tries {
    my ( $self, $file, $string, $max_tries ) = @_;
    my $ok = $self->_count_tries( $file, $string, $max_tries );
    if ( !$ok ) {
      $self->logger->error("Too many incorrect tries $file, $string");
      return ( $ok, $too_many_tries );

    }
    return ( $ok, undef );
  }

=head2 _count_tries

Returns true if the number of occurrences of string in file is greater than or equal to
max_tries.

Returns false if the file is missing or contains less occurrences than max_tries.

=cut

  #*****************************************************************************
  sub _count_tries {

    #*****************************************************************************
    my ( $self, $file, $string, $max_tries ) = @_;
    my $ok = 1;
    my @lines;
    $self->logger->debug("file=$file string=$string max_tries=$max_tries");

    if ( -f $file ) {
      @lines = slurp($file);
    }
    my $count = grep /^$string$/, @lines;
    if ( $count >= $max_tries ) {
      $ok = 0;
    }
    return $ok;
  }

=head2 _write_tries

=cut

  #*****************************************************************************
  sub _write_tries {

    #*****************************************************************************
    my $self   = shift;
    my $file   = shift;
    my $string = shift;
    my $ok     = 0;
    my $FP;
    if ( !open( $FP, ">>", $file ) ) {
      $self->logger->error("Unable to open $file or writing.");
      $ok = 0;
    }
    else {
      print $FP $string . "\n";
      close $FP;
    }
    return $ok;
  }

=head2 _compare_characters

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

=head2 _get_suffix

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

=head2 _get_wrong_file

Returns the full filename of the wrong file.

=cut

  #*****************************************************************************
  sub _get_wrong_file {

    #*****************************************************************************
    my $self = shift;
    return ( $self->get_pwd_dir || "" ) . '/' . ( $self->{WRONGFILE} || "" );
  }

=head2 _get_vwrong_file

Returns the full filename of the very wrong file.

=cut

  #*****************************************************************************
  sub _get_vwrong_file {

    #*****************************************************************************
    my $self = shift;
    return ( $self->get_pwd_dir || "" ) . '/' . ( $self->{VWRONGFILE} || "" );
  }

=head2 _set_vwrong_file

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

=head2 set_wrong_file

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

=head2 get_pwd_dir

Returns the directory which contains the wrong file and the very wrong file.

=cut

  #*****************************************************************************
  sub get_pwd_dir {

    #*****************************************************************************
    my $self = shift;
    return $self->{PWDDIR};
  }

  1;
