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

=head1 ISA Fcerror

Inherits

=over

=item logger

=back

=cut

=head1 METHODS AND FUNCTIONS

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

  our @ISA = qw/Fcerror/;

  # Class variables
  $Fcutils2::LOGDIR  = "";
  $Fcutils2::LOCKDIR = $Fcutils2::LOGDIR;
  $Fcutils2::OLDFILE = "";
  $Fcutils2::TIMEOUT = 105;

=head2 Functions

=cut

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

=head3 ApacheTime

=cut

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

=head2 External Methods

=cut

=head3 Constructor

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

    $self->{APPEND_TO_LOGFILE} = 'N';
    if ( $args{-append_to_logfile} =~ m/Y/i ) {
      $self->set_append_logfile('Y');
    }

    $self->{AUTO_CLEAN} = 'N';
    if ( $args{-auto_clean} =~ m/Y/i ) {
      $self->set_auto_clean('Y');
    }

    $self->{SAVE_DAYS}    = 30;
    $self->{LOGFILE_STEM} = "_NONE_";

    return $self;

  }    # End constructor

=head3 set_auto_clean

=cut

  #*****************************************************************************
  sub set_auto_clean {

    #*****************************************************************************
    my $self = shift;
    my $v    = shift;
    if ( $v =~ m/^[yn]$/i ) {
      $self->{AUTO_CLEAN} = uc($v);
    }
  }

=head3 get_auto_clean

=cut

  #*****************************************************************************
  sub get_auto_clean {

    #*****************************************************************************
    my $self = shift;
    return $self->{AUTO_CLEAN};
  }

=head3 auto_clean

=cut

  #*****************************************************************************
  sub auto_clean {

    #*****************************************************************************
    my $self = shift;
    my $err  = 0;
    my $FP;
    my $stem;
    my $num_files   = 0;
    my $num_matches = 0;
    my $num_too_old = 0;

    $self->logger->debug( "Start auto_clean. " . $self->get_auto_clean );
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

        $num_files++;
        my $st = stat($ff);
        if ( $f =~ m/^$stem.*log$/ ) {
          $num_matches++;
          if ( $st->mtime < $t ) {
            $num_too_old++;
            $self->logger->debug("Delete old log file $ff");
            unlink($ff)
              || do { $self->logger->error( "Unable to delete old log file $ff. " . $! ); $err = 1; }
          }
        }

      }

    }
    $self->logger->debug("$num_files files $num_matches match $stem $num_too_old too old.");
    close $FP;
    return $err;
  }

=head3 set_logfile_stem

=cut

  #*****************************************************************************
  sub set_logfile_stem {

    #*****************************************************************************
    my ( $self, $v ) = @_;
    $self->{LOGFILE_STEM} = $v;
    return 1;
  }

=head3 SetLogDir

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

=head3 OpenLogFile

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

=head3 CloseLogFile

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

=head3 OpenLockFile

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

=head3 CloseLockFile

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

=head3 get_lock_file

=cut

  #*****************************************************************************
  sub get_lock_file

    #*****************************************************************************
  {
    my $self = shift;
    return $self->{LOCKFILE};
  }

=head3 get_lock_dir

=cut

  #*****************************************************************************
  sub get_lock_dir

    #*****************************************************************************
  {
    my $self = shift;
    return $self->{LOCKDIR};
  }

=head3 set_lock_dir

=cut

  #*****************************************************************************
  sub set_lock_dir

    #*****************************************************************************
  {
    my $self = shift;
    $self->{LOCKDIR} = shift;
  }

=head2 Internal Methods

=cut

=head3 _keep_before_time

=cut

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

=head3 _get_save_seconds

=cut

  #*****************************************************************************
  sub _get_save_seconds {

    #*****************************************************************************
    my $self = shift;
    return $self->get_save_days() * 24 * 60 * 60;
  }

=head3 set_save_days

=cut

  #*****************************************************************************
  sub set_save_days {

    #*****************************************************************************
    my $self = shift;
    $self->{SAVE_DAYS} = shift;
  }

=head3 get_save_days

=cut

  #*****************************************************************************
  sub get_save_days {

    #*****************************************************************************
    my $self = shift;
    return $self->{SAVE_DAYS};
  }

=head3 set_append_logfile

=cut

  #*****************************************************************************
  sub set_append_logfile {

    #*****************************************************************************
    my $self = shift;
    my $v    = shift;
    if ( $v =~ m/^[yn]$/i ) {
      $self->{APPEND_TO_LOGFILE} = uc($v);
    }
  }

=head3 get_append_logfile

=cut

  #*****************************************************************************
  sub get_append_logfile {

    #*****************************************************************************
    my $self = shift;
    return $self->{APPEND_TO_LOGFILE};
  }

=head3 _get_logfile_stem

=cut

  #*****************************************************************************
  sub _get_logfile_stem {

    #*****************************************************************************
    my $self = shift;
    return $self->{LOGFILE_STEM};
  }

=head3 GetLogDir

=cut

  #*****************************************************************************
  sub GetLogDir

    #*****************************************************************************
  {
    my $self = shift;
    return $self->{LOGDIR};
  }

=head3 IsUnix

=cut

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

=head3 _create_suffix

=cut

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

=head3 GetLogFileName

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

=head3 DESTROY

=cut

  #*****************************************************************************
  # Close the lock file if this object opened it.
  sub DESTROY {
    my $self = shift;
    $self->logger->debug( "In DESTROY " . ( $self->{IOPENEDLOCKFILE} || "" ) );
    $self->CloseLockFile() if $self->{IOPENEDLOCKFILE};
    1;
  }

  1;
}    # End package Fcutils
