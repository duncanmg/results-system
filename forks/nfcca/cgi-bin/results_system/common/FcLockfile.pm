=head1 NAME

FcLockfile Package

=cut

=head1 SYNOPSIS

Lock file functionality.

=cut

=head1 ISA Fcerror

Inherits

=over

=item logger

=back

=cut

=head1 METHODS

=cut

#***********************************************************************
#
# Name Fcutils.pm
#
#***********************************************************************

{

  package FcLockfile;

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
  $FcLockfile::TIMEOUT = 105;

=head2 External Methods

=cut

=head3 Constructor

Create the object and gives it an error object. Binds in the current values of
the class variables LOCKDIR, OLDFILE.

=cut

  #*****************************************************************************
  sub new

    #*****************************************************************************
  {
    my ($class,%args) = @_;
    my $self = {};
    bless $self, $class;

    my $err = 0;
    $self->set_lock_dir($args{-lock_dir}) if $args{-lock_dir};
    $self->{LOCKFILETRIES}   = 0;

    return $self;

  }    # End constructor

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

    while ( -e $lockfile && $count < $FcLockfile::TIMEOUT ) {
      $count = $count + 1;
      sleep 1;
    }

    if ( $count >= $FcLockfile::TIMEOUT ) {
      $self->logger->warn(
        "Unable to create lock file after $FcLockfile::TIMEOUT tries. Overwrite it.");
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

=head3 DESTROY

Close the lock file if this object opened it.

=cut

  #*****************************************************************************
  sub DESTROY {
    my $self = shift;
    $self->logger->debug( "In DESTROY " . ( $self->{IOPENEDLOCKFILE} || "" ) );
    $self->CloseLockFile() if $self->{IOPENEDLOCKFILE};
    1;
  }

  1;
}    # End package Fcutils