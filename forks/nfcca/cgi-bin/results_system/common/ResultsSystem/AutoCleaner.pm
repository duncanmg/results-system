
=head1 NAME

ResultsSystem::AutoCleaner

=cut

=head1 SYNOPSIS

  my $cleaner = ResultsSystem::AutoCleaner->new(
     { -logger => $logger, -configuration => $configuration });
  $cleaner->set_log_dir( $log_dir );
  $cleaner->set_logfile_stem( $stem );
  $cleaner->auto_clean;

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::AutoCleaner;

use strict;
use warnings;

use Data::Dumper;
use Params::Validate qw/ :all /;
use File::stat;
use Time::localtime;
use Carp;

use ResultsSystem::Exception;

=head2 new

 my $cleaner = ResultsSystem::AutoCleaner->new(
   { -logger => $logger, -configuration => $configuration });

=cut

#*****************************************************************************
sub new

  #*****************************************************************************
{
  my ( $class, $args ) = validate_pos( @_, 1, { type => HASHREF, optional => 1 } );
  my $self = {};
  bless $self, $class;

  $self->{logger}        = $args->{-logger}        if $args->{-logger};
  $self->{configuration} = $args->{-configuration} if $args->{-configuration};

  $self->set_auto_clean('Y');

  # $self->set_log_dir( $args{-log_dir} ) if $args{-log_dir};

  # $self->set_logfile_stem( $args{-logfile_stem} ) if $args{-logfile_stem};

  return $self;

}    # End constructor

=head2 set_auto_clean

=cut

#*****************************************************************************
sub set_auto_clean {

  #*****************************************************************************
  my $self = shift;
  my $v    = shift;
  if ( $v =~ m/^[yn]$/xi ) {
    $self->{AUTO_CLEAN} = uc($v);
  }
  return 1;
}

=head2 auto_clean

Does nothing unless get_auto_clean() returns "Y".

Searches the directory returned by get_log_dir. It then deletes any files which
match a given pattern and are older than the time returned by _keep_after_time.

The pattern is the file name should begin with the string returned by 
get_logfile_stem and end with ".log".

=cut

#*****************************************************************************
sub auto_clean {

  #*****************************************************************************
  my $self = shift;
  my $FP;
  my $num_files   = 0;
  my $num_too_old = 0;

  $self->{logger}->debug( "Start auto_clean. " . $self->get_auto_clean );
  return if $self->get_auto_clean ne 'Y';

  my $d = $self->get_log_dir;
  opendir( $FP, $d )
    || croak ResultsSystem::Exception->new( 'UNABLE_TO_OPEN_DIR', "Unable to open log dir $d." );

  my @files = readdir $FP;

  foreach my $f (@files) {

    my $ff = $d . "/" . $f;

    next if ( -d $ff );

    $num_files++;

    next if !$self->ready_for_deletion($ff);

    $num_too_old++;
    $self->{logger}->debug("Delete old log file $ff");

    unlink($ff)
      || do {
      $self->logger->error( "Unable to delete old log file $ff. " . $! );
      };
  }
  $self->{logger}->debug("Checked $num_files files $num_too_old match stem and are too old.");
  close $FP;
  return 1;
}

=head2 set_logfile_stem

=cut

#*****************************************************************************
sub set_logfile_stem {

  #*****************************************************************************
  my ( $self, $v ) = @_;
  $self->{LOGFILE_STEM} = $v;
  return $self;
}

=head2 set_log_dir

Set the log directory.

=cut

#*****************************************************************************
sub set_log_dir

  #*****************************************************************************
{
  my $self = shift;
  $self->{LOGDIR} = shift;
  if ( !-d $self->get_log_dir ) {
    $self->{logger}->error( "Log directory does not exist. " . $self->get_log_dir );
  }
  return $self;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _keep_after_time

Returns the current time in seconds minus the number of seconds which a log file
should be kept for. Uses _get_save_seconds.

=cut

#*****************************************************************************
sub _keep_after_time {

  #*****************************************************************************
  my $self = shift;
  my $err  = 0;

  my $tm     = time();
  my $period = $self->_get_save_seconds;
  my $t      = $tm - $period;

  return $t;

}

=head2 _get_save_seconds

Return the number of seconds to save a log file. Converts the figure returned by
get_save_days.

=cut

#*****************************************************************************
sub _get_save_seconds {

  #*****************************************************************************
  my $self = shift;
  return $self->get_save_days() * 24 * 60 * 60;
}

=head2 set_save_days

=cut

#*****************************************************************************
sub set_save_days {

  #*****************************************************************************
  my $self = shift;
  $self->{SAVE_DAYS} = shift;
  return 1;
}

=head2 get_save_days

Return the number of days to save a log file. Defaults to 30.

Cannot be 0.

=cut

#*****************************************************************************
sub get_save_days {

  #*****************************************************************************
  my $self = shift;
  return $self->{SAVE_DAYS} || 30;
}

=head2 get_log_dir

=cut

#*****************************************************************************
sub get_log_dir

  #*****************************************************************************
{
  my $self = shift;
  return $self->{LOGDIR};
}

=head2 logger

  $self->logger->debug( "A message." );

=cut

sub logger {
  my $self = shift;
  return $self->{logger};
}

=head2 get_configuration

=cut

sub get_configuration {
  my $self = shift;
  return $self->{configuration};
}

=head2 ready_for_deletion

=cut

sub ready_for_deletion {
  my ( $self, $full_filename ) = validate_pos( @_, 1, 1 );

  my $t    = $self->_keep_after_time;
  my $stem = $self->get_logfile_stem;
  my $st   = stat($full_filename);

  return if !( $full_filename =~ m/^$stem.*log$/x );

  return if !( $st->mtime < $t );

  return 1;
}

=head2 get_auto_clean

=cut

#*****************************************************************************
sub get_auto_clean {

  #*****************************************************************************
  my $self = shift;
  return $self->{AUTO_CLEAN};
}

=head2 get_logfile_stem

=cut

#*****************************************************************************
sub get_logfile_stem {

  #*****************************************************************************
  my $self = shift;
  croak ResultsSystem::Exception->new( 'LOGFILE_STEM_NOT_SET', 'The logfile stem is not set' )
    if !$self->{LOGFILE_STEM};
  return $self->{LOGFILE_STEM};
}

1;
