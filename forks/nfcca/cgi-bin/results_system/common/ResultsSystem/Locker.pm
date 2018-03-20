
=head1 NAME

ResultsSystem::Locker Package

=cut

=head1 SYNOPSIS

Lock file functionality.

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

#***********************************************************************
#
# Name ResultsSystem::Locker.pm
#
#***********************************************************************

package ResultsSystem::Locker;

use strict;
use warnings;

use Params::Validate qw/:all/;

use ResultsSystem::Exception;

use Time::localtime;
use Carp;

# Class variables
$ResultsSystem::Locker::TIMEOUT = 105;

=head2 new

  my $locker = 
    ResultsSystem::Locker->new( { -logger => $logger, -configuration => $config } );

=cut

#*****************************************************************************
sub new

  #*****************************************************************************
{
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->{configuration} = $args->{-configuration} if $args->{-configuration};
  $self->{logger}        = $args->{-logger}        if $args->{-logger};

  $self->logger->debug('Locker created') if $self->get_configuration;
  return $self;

}    # End constructor

=head2 open_lock_file

Create a file in the directory LOCKDIR with the name lockfile.lock where lockfile
is the name passed as a parameter.

eg $err=$utils->open_lock_file("cteam");

The above statement creates the file cteam.lock.

Should really be called CreateLockFile because the file is created then closed.

=cut

#*****************************************************************************
sub open_lock_file

  #*****************************************************************************
{
  my ( $self, $lockfile ) = validate_pos( @_, 1, 0 );
  my $count = 0;
  my $LOCKFILE;

  $self->set_lock_file($lockfile) if $lockfile;

  my $ff = $self->get_lock_full_filename;

  while ( $self->check_lock_file_exists && $count < $ResultsSystem::Locker::TIMEOUT ) {
    $count = $count + 1;
    sleep 1;
  }

  if ( $count >= $ResultsSystem::Locker::TIMEOUT ) {
    $self->logger->warn(
      "Unable to create lock file after $ResultsSystem::Locker::TIMEOUT tries. Overwrite it.");
  }

  open( $LOCKFILE, ">", $ff ) || do {
    croak(
      ResultsSystem::Exception->new( 'UNABLE_TO_OPEN_FILE', "Unable to open file. $ff. " . $! ) );
  };

  print $LOCKFILE $ff . "\n";
  close $LOCKFILE;
  $self->logger->debug("Lockfile created. $ff");
  $self->{ IOPENED $LOCKFILE} = 1;

  return 1

}    # End open_lock_file()

=head2 close_lock_file

Deletes the lockfile.

=cut

#*****************************************************************************
sub close_lock_file

  #*****************************************************************************
{
  my $self     = shift;
  my $lockfile = $self->get_lock_full_filename;

  return 1 if !$self->check_lock_file_exists;

  unlink $lockfile || do {
    $self->logger->error( "Can not delete lockfile " . $lockfile . " " . $! );
    $self->{IOPENEDLOCKFILE} = undef;
  };

  $self->logger->debug("Finished close_lock_file(). ");
  return 1;
}

=head2 check_lock_file_exists

=cut

sub check_lock_file_exists {
  my $self = shift;
  return ( -e $self->get_lock_full_filename ) ? 1 : undef;
}

=head2 get_lock_full_filename

=cut

#*****************************************************************************
sub get_lock_full_filename

  #*****************************************************************************
{
  my $self = shift;
  return $self->get_lock_dir . '/' . $self->get_lock_file;
}

=head2 get_lock_file

=cut

#*****************************************************************************
sub get_lock_file

  #*****************************************************************************
{
  my $self = shift;
  if ( !$self->{LOCKFILE} ) {
    my $c = $self->get_configuration;
    $self->set_lock_file( $c->get_log_stem ) if $c;
  }

  return $self->{LOCKFILE};
}

=head2 set_lock_file

Cleans and sets the lock file.

=cut

sub set_lock_file {
  my ( $self, $lockfile ) = validate_pos( @_, 1, { -type => SCALAR } );
  $lockfile =~ s/[^A-Za-z0-9._]//xg;    # Clean the filename.

  if ( $lockfile !~ m/\./x ) { $lockfile = $lockfile . "."; }
  if ( $lockfile !~ m/\.[a-zA-Z0-9_-]{1,}$/x ) { $lockfile =~ s/\.[^.]*$/\.lock/x; }
  $self->{LOCKFILE} = $lockfile;
  return $self;
}

=head2 get_lock_dir

=cut

#*****************************************************************************
sub get_lock_dir

  #*****************************************************************************
{
  my $self = shift;

  if ( !$self->{LOCKDIR} ) {
    my $c = $self->get_configuration;
    $self->set_lock_dir( $c->get_path( -log_dir => 'Y' ) ) if $c;
  }

  croak(
    ResultsSystem::Exception->new(
      'DIR_DOES_NOT_EXIST', 'Lock dir does not exist ' . $self->{LOCKDIR}
    )
  ) if !-d $self->{LOCKDIR};
  return $self->{LOCKDIR};
}

=head2 set_lock_dir

=cut

#*****************************************************************************
sub set_lock_dir

  #*****************************************************************************
{
  my $self = shift;
  $self->{LOCKDIR} = shift;
  return 1;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 logger

=cut

sub logger { my $self = shift; return $self->{logger}; }

=head2 get_configuration

=cut

sub get_configuration { my $self = shift; return $self->{configuration}; }

=head2 DESTROY

Close the lock file if this object opened it.

=cut

#*****************************************************************************
sub DESTROY {
  my $self = shift;
  $self->logger->debug( "In DESTROY " . ( $self->{IOPENEDLOCKFILE} || "" ) );
  $self->close_lock_file() if $self->{IOPENEDLOCKFILE};
  return 1;
}

1;
