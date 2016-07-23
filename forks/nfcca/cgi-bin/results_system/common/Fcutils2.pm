#************************************************************************
#
# 0.1  - 20 May 08 - Created from Fcutils
# 0.2  - 01 Feb 09 - Remove fcGlobals.pm
#
#************************************************************************

=head1 NAME

Fcutils2 Package

=cut

=head1 SYNOPSIS

Utilities.

=cut

=head1 METHODS

=cut

#***********************************************************************
#
# Name Fcutils.pm
#
#***********************************************************************

{

  package Fcutils2;

  use strict;
  use List::MoreUtils qw( first_index any );
  use File::stat;

  use Slurp;
  use File::Copy;
  use File::Compare;
  use Time::localtime;
  use Fcerror;

  our @ISA;
  unshift @ISA, "Fcwrapper";

  # Class variables
  $Fcutils2::LOGDIR             = "";
  $Fcutils2::LOCKDIR            = $Fcutils2::LOGDIR;
  $Fcutils2::OLDFILE            = "";
  $Fcutils2::TIMEOUT            = 105;
  $Fcutils2::DEFAULTPERMISSIONS = 0660;                # Octal representation of rw-rw----

  #***************************************************..***************************
  # The two global variables and the three functions (signal_handler(), AddToLockList(),
  # RemoveFromLockList()) are use to delete any lock
  # files created by the process if the process is killed.
  # They are functions, not methods, and keep track of all the lock files created by
  # the process, not just a particular instance.
  # *****************************************************************************

  # $Fcutils2::g_NumLockFiles = 0;    # The number of lock files in existence.
  # @Fcutils2::g_LockFileNames;   # The filenames and full paths.

  # $Fcutils2::g_NumUtilsObjects = 0;

  # @Fcutils2::g_UtilsObjects;    # The error objects. NB Potential memory leak here!

  #******************************************************************************
  # Function which returns GMT in format DD/Mon/YYYY:HH24:MI:SS
  #******************************************************************************
  sub ApacheTime

    #******************************************************************************
  {
    my $t;
    if   ( !$_[0] ) { $t = time(); }
    else            { $t = $_[0]; }
    my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = gmtime($t);
    my $monname  = (qw(Jan Feb Mar Apr May Jun Jul Aug Sep Oct Nov Dec))[$mon];
    my $wdname   = (qw(Sun Mon Tue Wed Thu Fri Sat))[$wday];
    my $fullyear = $year + 1900;
    if ( length $sec < 2 )  { $sec  = "0" . $sec; }
    if ( length $min < 2 )  { $min  = "0" . $min; }
    if ( length $hour < 2 ) { $hour = "0" . $hour; }
    if ( length $mday < 2 ) { $mday = " " . $mday; }
    return $wdname . " " . $monname . " " . $mday . " " . $hour . ":" . $min . ":" . $sec . " "
      . $fullyear;
  }    # End ApacheTime()

=head2 Constructor

Create the object and gives it an error object. Binds in the current values of
the class variables LOGDIR, LOCKDIR, OLDFILE.

=cut

  #*****************************************************************************
  sub new

    #*****************************************************************************
  {
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    my $err = 0;
    $self->{OLDFILE}         = $Fcutils2::OLDFILE;
    $self->{LOCKDIR}         = $Fcutils2::LOCKDIR;
    $self->{LOGDIR}          = $Fcutils2::LOGDIR;
    $self->{LOGFILEREDIRECT} = 0;
    $self->{LOCKFILETRIES}   = 0;
    $self->{TIMECREATED}     = time();
    $self->setPermissions($Fcutils2::DEFAULTPERMISSIONS);

    $self->{APPEND_TO_LOGFILE} = 'N';
    if ( $args{-append_to_logfile} =~ m/Y/i ) {
      $self->set_append_logfile('Y');
    }

    $self->{AUTO_CLEAN} = 'N';
    if ( $args{-auto_clean} =~ m/Y/i ) {
      $self->set_auto_clean('Y');
    }

    $self->set_pwd_dir( $self->GetLogDir );
    $self->set_wrong_file("wrong");
    $self->_set_vwrong_file("vwrong");

    $self->{SAVE_DAYS}    = 30;
    $self->{LOGFILE_STEM} = "_NONE_";

    return $self;

  }    # End constructor

  #*****************************************************************************
  sub set_auto_clean {

    #*****************************************************************************
    my $self = shift;
    my $v    = shift;
    if ( $v =~ m/^[yn]$/i ) {
      $self->{AUTO_CLEAN} = uc($v);
    }
  }

  #*****************************************************************************
  sub get_auto_clean {

    #*****************************************************************************
    my $self = shift;
    return $self->{AUTO_CLEAN};
  }

  #*****************************************************************************
  sub auto_clean {

    #*****************************************************************************
    my $self = shift;
    my $err  = 0;
    my $FP;
    my $stem;

    if ( $self->get_auto_clean ne 'Y' ) {
      return $err;
    }

    my $d = $self->GetLogDir;
    if ( !opendir( $FP, $d ) ) {
      $self->logger->error("auto_clean(): Unable to open log dir $d.");
      $err = 1;
    }
    else {

      my @files = readdir $FP;

      my $t = $self->_keep_before_time;
      $stem = $self->_get_logfile_stem;

      foreach my $f (@files) {

        my $ff = $d . "/" . $f;

        if ( -d $ff ) {
          next;
        }

        my $st = stat($ff);
        if ( $f =~ m/^$stem.*log$/ ) {
          if ( $st->mtime < $t ) {
            unlink $ff;
          }
        }

      }

    }
    close $FP;
    return $err;
  }

  #*****************************************************************************
  sub _keep_before_time {

    #*****************************************************************************
    my $self = shift;
    my $err  = 0;

    my $tm     = time();
    my $period = $self->_get_save_seconds;
    my $t      = $tm - $period;

    return $t;

  }

  #*****************************************************************************
  sub _get_save_seconds {

    #*****************************************************************************
    my $self = shift;
    return $self->get_save_days() * 24 * 60 * 60;
  }

  #*****************************************************************************
  sub set_save_days {

    #*****************************************************************************
    my $self = shift;
    $self->{SAVE_DAYS} = shift;
  }

  #*****************************************************************************
  sub get_save_days {

    #*****************************************************************************
    my $self = shift;
    return $self->{SAVE_DAYS};
  }

  #*****************************************************************************
  sub set_append_logfile {

    #*****************************************************************************
    my $self = shift;
    my $v    = shift;
    if ( $v =~ m/^[yn]$/i ) {
      $self->{APPEND_TO_LOGFILE} = uc($v);
    }
  }

  #*****************************************************************************
  sub get_append_logfile {

    #*****************************************************************************
    my $self = shift;
    return $self->{APPEND_TO_LOGFILE};
  }

  #*****************************************************************************
  sub _get_logfile_stem {

    #*****************************************************************************
    my $self = shift;
    return $self->{LOGFILE_STEM};
  }

=head2 SetLogDir

Set the log directory.

=cut

  #*****************************************************************************
  sub SetLogDir

    #*****************************************************************************
  {
    my $self = shift;
    my $err  = 0;
    $self->{LOGDIR} = shift;
    if ( !-d $self->GetLogDir ) {
      $self->logger->error( "Log directory does not exist. " . $self->GetLogDir );
      $err = 1;
    }
    return $err;
  }

  #*****************************************************************************
  sub GetLogDir

    #*****************************************************************************
  {
    my $self = shift;
    return $self->{LOGDIR};
  }

  #*****************************************************************************
  sub IsUnix

    #*****************************************************************************
  {
    my $self  = shift;
    my $opsys = $^O;
    my $unix  = 0;
    if ( $opsys !~ m/win/i ) { $unix = 1; }
    return $unix;
  }

  #*****************************************************************************
  # Use a function to calculate the suffix.
  sub _create_suffix {

    #*****************************************************************************
    my $self = shift;
    my $lt   = localtime();

    my $tmp = $lt->yday;
    while ( length $tmp < 3 ) { $tmp = '0' . $tmp; }
    my $suffix = $tmp;

    if ( $self->get_append_logfile() eq 'N' ) {

      $tmp = $lt->hour;
      while ( length $tmp < 2 ) { $tmp = '0' . $tmp; }
      $suffix = $suffix . $tmp;

      $tmp = $lt->min;
      while ( length $tmp < 2 ) { $tmp = '0' . $tmp; }
      $suffix = $suffix . $tmp;

      $tmp = $lt->sec;
      while ( length $tmp < 2 ) { $tmp = '0' . $tmp; }
      $suffix = $suffix . $tmp;

      $tmp = int( rand(100) );
      while ( length $tmp < 2 ) { $tmp = '0' . $tmp; }

      $suffix = $suffix . $tmp;

    }

    return $suffix;

  }

=head2 OpenLogFile

Not needed any more. Will be removed at some point.

=cut

  #*****************************************************************************
  sub OpenLogFile

    #*****************************************************************************
  {
    my ( $self, $logfile ) = @_;
    my $err   = 0;
    my $count = 0;
    my $LOGFILE;

    $self->logger(1)->debug("OpenLogFile called()");

    return ( $err, $LOGFILE );
  }    # End OpenLogFile()

=head2 CloseLogFile

Don't need this any more.

=cut

  #*****************************************************************************
  sub CloseLogFile

    #*****************************************************************************
  {
    my $self = shift;
    my $err  = 0;

    return $err;
  }    # End CloseLogFile()

=head2 GetLogFileName

Return the name of the open log file. If a parameter is provided then the path is
returned as well.

=cut

  #*****************************************************************************
  sub GetLogFileName

    #*****************************************************************************
  {
    my $self = shift;
    my $full = shift;
    my $name = $self->{LOGFILENAME};
    if ( $full eq undef ) {
      $name =~ s/^.*?([^\/\\]{1,})$/$1/;
    }
    return $name;
  }

=head2 OpenLockFile

Create a file in the directory LOCKDIR with the name lockfile.lock where lockfile
is the name passed as a parameter.

eg $err=$utils->OpenLockFile("cteam");

The above statement creates the file cteam.lock.

Should really be called CreateLockFile because the file is created then closed.

=cut

  #*****************************************************************************
  sub OpenLockFile

    #*****************************************************************************
  {
    my $self     = shift;
    my $err      = 0;
    my $count    = 0;
    my $lockfile = shift;
    $lockfile =~ s/[^A-Za-z0-9._]//g;    # Clean the filename.

    if ( length($lockfile) == 0 ) {
      $self->logger->error("OpenLockFile(): Parameter was null or invalid.");
      $err = 1;
    }

    # print $lockfile;
    if ( $lockfile !~ m/\./ ) { $lockfile = $lockfile . "."; }
    if ( $lockfile !~ m/\.[a-zA-Z0-9_-]{1,}$/ ) { $lockfile =~ s/\.[^.]*$/\.lock/; }
    $lockfile = $self->get_lock_dir . "/" . $lockfile;
    $self->{LOCKFILE} = $lockfile;

    # If the lockfile ends in .lock, use a similar .old file. Otherwise just leave the default.
    if ( $self->{LOCKFILE} =~ m/\.lock$/ ) {
      $self->{OLDFILE} = $self->{LOCKFILE};
      $self->{OLDFILE} =~ s/\.lock$/\.old/;
    }

    while ( -e $lockfile && $count < $Fcutils2::TIMEOUT ) {
      $count = $count + 1;
      sleep 1;
    }

    if ( $count >= $Fcutils2::TIMEOUT ) {
      $self->logger->warn(
        "Unable to create lock file after $Fcutils2::TIMEOUT tries. Overwrite it.");
    }

    $self->{LOCKFILETRIES} = $count;

    if ( $err == 0 ) {
      if ( !open( LOCKFILE, ">" . $lockfile ) ) {
        $err = 1;
        $self->logger->error( "Unable to open file. $lockfile. " . $! );
      }
    }

    if ( $err == 0 ) {
      print LOCKFILE $lockfile . "\n";
      close LOCKFILE;
      $self->logger->debug("Lockfile created. $lockfile");
      $self->{IOPENEDLOCKFILE} = 1;
    }

    return $err;

  }    # End OpenLockFile()

=head2 CloseLockFile

Doesn't close or delete the lockfile as such. Moves it to OLDFILE.

Ummm ... looks like it deletes it to me.

=cut

  #*****************************************************************************
  sub CloseLockFile

    #*****************************************************************************
  {
    my $self = shift;
    my $err  = 0;
    my $ret;
    my $lockfile    = $self->{LOCKFILE};
    my $oldlockfile = $self->{OLDFILE};
    $self->logger->debug("CloseLockFile() called.");
    if ( !-e $lockfile ) {
      $self->logger->debug("Lockfile $lockfile does not exist.");
      return $err;
    }
    $ret = unlink $lockfile;
    if ( $ret != 1 ) {
      $self->logger->error( "Can not delete lockfile " . $lockfile . " " . $! );
      $err = 1;
      $self->{IOPENEDLOCKFILE} = undef;
    }
    $self->logger->debug( "Finished CloseLockFile(). " . $err );
    return $err;
  }

  #*****************************************************************************
  # Close the lock file if this object opened it.
  sub DESTROY {
    my $self = shift;
    $self->logger->debug( "In DESTROY " . ( $self->{IOPENEDLOCKFILE} || "" ) );
    $self->CloseLockFile() if $self->{IOPENEDLOCKFILE};
    1;
  }

  #*****************************************************************************
  sub get_lock_file

    #*****************************************************************************
  {
    my $self = shift;
    return $self->{LOCKFILE};
  }

  #*****************************************************************************
  sub get_lock_dir

    #*****************************************************************************
  {
    my $self = shift;
    return $self->{LOCKDIR};
  }

  #*****************************************************************************
  sub set_lock_dir

    #*****************************************************************************
  {
    my $self = shift;
    $self->{LOCKDIR} = shift;
  }

  #*****************************************************************************
  sub get_pwd_dir {

    #*****************************************************************************
    my $self = shift;
    return $self->{PWDDIR};
  }

  #*****************************************************************************
  sub set_pwd_dir {

    #*****************************************************************************
    my $self = shift;
    $self->{PWDDIR} = shift;
  }

  #*****************************************************************************
  sub _get_wrong_file {

    #*****************************************************************************
    my $self = shift;
    return $self->{WRONGFILE};
  }

  #*****************************************************************************
  sub set_wrong_file {

    #*****************************************************************************
    my $self = shift;
    my $stem = shift;
    if ($stem) {
      my $append = $self->get_append_logfile();
      if ( $append !~ m/Yy/i ) {
        $self->set_append_logfile("Y");
      }
      my $s  = $self->_create_suffix;
      my $vw = $stem . $s . ".log";
      $self->{WRONGFILE} = $vw;
      $self->set_append_logfile($append);
    }
  }

  #*****************************************************************************
  sub _get_vwrong_file {

    #*****************************************************************************
    my $self = shift;
    return $self->{VWRONGFILE};
  }

  #*****************************************************************************
  sub _set_vwrong_file {

    #*****************************************************************************
    my $self = shift;
    my $stem = shift;
    if ($stem) {
      my $append = $self->get_append_logfile();
      if ( $append !~ m/Yy/i ) {
        $self->set_append_logfile("Y");
      }
      my $s  = $self->_create_suffix;
      my $vw = $stem . $s . ".log";
      $self->{VWRONGFILE} = $vw;
      $self->set_append_logfile($append);
    }
  }

=head2 AssignCode

Return a 6 digit code.

=cut

  #*****************************************************************************
  sub AssignCode

    #*****************************************************************************
  {
    my $self = shift;
    my $code = rand(999999);
    while ( $code == 0 )    { $code = rand(999999); }
    while ( $code < 99999 ) { $code = $code * 10; }
    $code = int($code);
    while ( length $code < 6 ) { $code = "0" . $code; }
    return $code;
  }    # End Assign Code

=head2 CheckVeryWrong

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
    my $self     = shift;
    my $real_pwd = $_[0];    # The correct password.
    my $user_pwd = $_[1];    # The password entered by the user.
    my $teamfile = $_[2];    # A string which identifies the user.
    my $vwrong   = 0;
    my $err      = 0;
    my $x        = 0;
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

=head2 CheckCode

Accepts two 6 digit numbers and the number of a team. It compare the 2 numbers and
if they do not match, it returns 1, otherwise it returns 0.

It records the number of incorrect tries per team in a file.
If more than three incorrect tries have been made, and the current attempt is invalid,
it issue a "Too Many Tries" message. No further attempts will be validated that day.

=cut

  #*****************************************************************************
  sub CheckCode

    #*****************************************************************************
  {
    my $self = shift;
    my $err  = 0;
    my $msg;
    my $pwdfile;
    my $real_pwd = $_[0];
    my $user_pwd = $_[1];
    my $teamfile = $_[2];

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

  #*****************************************************************************
  sub setPermissions

    #*****************************************************************************
  {
    my $self = shift;
    $self->{FILEPERMISSIONS} = shift;
  }

  #*****************************************************************************
  sub getPermissions

    #*****************************************************************************
  {
    my $self = shift;
    return $self->{FILEPERMISSIONS};
  }

=head2 setFilePermissions

Accepts a filename and sets the permissions to the ones set by setPermissions().
The default is rw-rw---- which is 0660 in octal.

=cut

  #*****************************************************************************
  sub setFilePermissions

    #*****************************************************************************
  {
    my $self = shift;
    my $file = shift;
    my $err  = 0;
    my $ret  = chmod( $self->getPermissions(), $file );
    if ( $ret != 1 ) { $err = 1; }
    return $err;
  }

  1;
}    # End package Fcutils
