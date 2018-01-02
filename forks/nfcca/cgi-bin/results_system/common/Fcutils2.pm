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
  use FcLockfile;

  our @ISA = qw/Fcerror/;

  # Class variables
  $Fcutils2::LOGDIR  = "";
  $Fcutils2::OLDFILE = "";

=head2 External Methods

=cut

=head3 Constructor

Create the object and gives it an error object. Binds in the current values of
the class variables LOGDIR, OLDFILE.

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
    $self->{LOGDIR}          = $Fcutils2::LOGDIR;
    $self->{LOGFILEREDIRECT} = 0;
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

=head3 open_log_file

Not needed any more. Will be removed at some point.

=cut

  #*****************************************************************************
  sub open_log_file

    #*****************************************************************************
  {
    my ( $self, $logfile ) = @_;
    my $err   = 0;
    my $count = 0;
    my $LOGFILE;

    $self->logger(1)->debug("open_log_file called()");

    return ( $err, $LOGFILE );
  }    # End open_log_file()

=head3 close_log_file

Don't need this any more.

=cut

  #*****************************************************************************
  sub close_log_file

    #*****************************************************************************
  {
    my $self = shift;
    my $err  = 0;

    return $err;
  }    # End close_log_file()

=head3 get_locker

=cut

  sub get_locker {
    my ( $self, %args ) = @_;
    if ( !$self->{LOCKER} ) {
      $self->{LOCKER} = FcLockfile->new( %args || () );
    }
    return $self->{LOCKER};
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

  1;
}    # End package Fcutils
