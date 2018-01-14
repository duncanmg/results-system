
=head1 Logger

=cut

{

  package Logger;

  use strict;
  use warnings;
  use Log::Log4perl;
  use Log::Log4perl::Level;
  use Exporter;
  use Data::Dumper;
  use Params::Validate qw/ :all /;
  use List::MoreUtils qw( first_index any );
  use File::stat;
  use Slurp;
  use File::Copy;
  use File::Compare;
  use Time::localtime;
  use DateTime::Tiny;
  use File::Basename;

  our @ISA = qw/ Exporter /;

  our @EXPORT_OK = qw/ get_logger /;

  our $CONF_FILE = "./logger.conf";

=head2 ISA Exporter

=cut

=head2 Functions

=cut

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
    $self->{LOGFILEREDIRECT} = 0;
    $self->{TIMECREATED}     = time();

    $self->{APPEND_TO_LOGFILE} = 'N';
    if ( ( $args{-append_to_logfile} || "" ) =~ m/Y/i ) {
      $self->set_append_logfile('Y');
    }

    $self->{AUTO_CLEAN} = 'N';
    if ( ( $args{-auto_clean} || "" ) =~ m/Y/i ) {
      $self->set_auto_clean('Y');
    }

    $self->{SAVE_DAYS}    = 30;
    $self->{LOGFILE_STEM} = "_NONE_";

    $self->set_log_dir( $args{-log_dir} ) if $args{-log_dir};

    $self->set_logfile_stem( $args{-logfile_stem} ) if $args{-logfile_stem};

    return $self;

  }    # End constructor

=head3 logger

$self->logger->debug( "Use the existing logger if there is one." );

$self->logger(undef, 1)->debug( "Always use a new logger. Write to STDERR" );

$self->logger($dir, 1)->debug( "Always use a new logger. Write to file in $dir" );

=cut

  sub logger {
    my ( $self, $dir, $force ) = @_;

    if ( $force || !$self->{logger} ) {
      my $class = ref($self);
      $self->{logger} = $self->get_logger( $class, $self->logfile_name($dir) );

    }
    return $self->{logger};
  }

=head3 screen_logger

Log to screen (STDERR) using the default configuration.

$logger = $self->screen_logger();

=cut

  sub screen_logger {
    my ( $self, $category ) = validate_pos( @_, 1, 0 );

    $category = 'Default' if !$category;
    my $conf = $self->default_conf();

    Log::Log4perl::init($conf);

    my $logger = Log::Log4perl::get_logger($category);

    return $logger;

  }

=head3 logfile_name

Return the existing logfile_name or undef:

$self->logfile_name();

Set the logfile_name and use the given directory:

If called on 28 Apr 2013

my $logfile_name = $self->logfile_name( "/tmp" );

will set $logfile_name to "/tmp/rs28.log"

=cut

  sub logfile_name {
    my ( $self, $dir ) = @_;
    my $now = DateTime::Tiny->now();
    if ($dir) {
      $self->{logfilename} = sprintf( "%s/%s%02d.log", $dir, "rs", $now->day );

      # $self->delete_old_logfile( $now, $dir );
    }
    return $self->{logfilename};
  }

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

Does nothing unless get_auto_clean() returns "Y".

Searches the directory returned by get_log_dir. It then deletes any files which
match a given pattern and are older than the time returned by _keep_after_time.

The pattern is th t the file name should begin with the string returned by 
get_logfile_stem and end with ".log".

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

    $self->{logger}->debug( "Start auto_clean. " . $self->get_auto_clean );
    if ( $self->get_auto_clean ne 'Y' ) {
      return $err;
    }

    my $d = $self->get_log_dir;
    if ( !opendir( $FP, $d ) ) {
      $self->{logger}->error("auto_clean(): Unable to open log dir $d.");
      $err = 1;
    }
    else {

      my @files = readdir $FP;

      my $t = $self->_keep_after_time;
      $stem = $self->get_logfile_stem;

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
            $self->{logger}->debug("Delete old log file $ff");
            unlink($ff)
              || do {
              $self->{logger}->error( "Unable to delete old log file $ff. " . $! );
              $err = 1;
              }
          }
        }

      }

    }
    $self->{logger}->debug("$num_files files $num_matches match $stem $num_too_old too old.");
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

=head3 set_log_dir

Set the log directory.

=cut

  #*****************************************************************************
  sub set_log_dir

    #*****************************************************************************
  {
    my $self = shift;
    my $err  = 0;
    $self->{LOGDIR} = shift;
    if ( !-d $self->get_log_dir ) {
      $self->{logger}->error( "Log directory does not exist. " . $self->get_log_dir );
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

    $self->{logger}->debug("open_log_file called()");

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

=head3 get_logfile_stem

=cut

  #*****************************************************************************
  sub get_logfile_stem {

    #*****************************************************************************
    my $self = shift;
    return $self->{LOGFILE_STEM};
  }

=head2 Internal Methods

=cut

=head3 default_conf

Default configuration

=cut

  sub default_conf {
    my $self = shift;
    return {
      "log4perl.rootLogger"             => "INFO , Screen",
      "log4perl.appender.Screen"        => "Log::Log4perl::Appender::Screen",
      "log4perl.appender.Screen.stderr" => 1,
      "log4perl.appender.Screen.layout" => "Log::Log4perl::Layout::PatternLayout",
      "log4perl.appender.Screen.layout.ConversionPattern" =>
        "[%d{dd/MMM/yyyy:HH:mm:ss}] %c %p %F{1} %M %L - %m%n"
    };
  }

=head3 conf_with_logfile

Used when a valid log file has been provided, but there is no configuration
file.

=cut

  sub conf_with_logfile {
    my $self = shift;
    my $file = shift;
    return {
      "log4perl.rootLogger"                    => "INFO , LOGFILE",
      "log4perl.category.ResultsConfiguration" => "INFO , LOGFILE",
      "log4perl.category.Fixtures"             => "INFO , LOGFILE",
      "log4perl.category.WeekFixtures"         => "INFO , LOGFILE",
      "log4perl.category.WeekData"             => "INFO , LOGFILE",
      "log4perl.appender.LOGFILE"              => "Log::Log4perl::Appender::File",
      "log4perl.appender.LOGFILE.filename"     => $file,
      "log4perl.appender.LOGFILE.mode"         => "append",
      "log4perl.appender.LOGFILE.layout"       => "Log::Log4perl::Layout::PatternLayout",
      "log4perl.appender.LOGFILE.layout.ConversionPattern" =>
        "[%d{dd/MMM/yyyy:HH:mm:ss}] %c %p %F{1} %M %L - %m%n",
    };
  }

=head3 get_logger

$logger = get_logger($category, $file);

category: Log4perl category

file: Full file messages will be logged to.

If $file is undefined or the directory does not exist then undefined is returned.

If the configuration file does not exists, undefined is returned.

=cut

  sub get_logger {
    my ( $self, $category, $file ) = validate_pos( @_, 1, 1, 0 );

    $category = 'Default' if !$category;
    my $conf = $self->get_conf($file);
    return if !$conf;

    Log::Log4perl::init($conf);

    my $logger = Log::Log4perl::get_logger($category);

    return $logger;

  }

=head3 get_conf

Return the log configuration file if it exists and if the log directory
exists. The log file does not have to exist.

Otherwise return undef.

=cut

  sub get_conf {
    my $self = shift;
    my $file = shift;

    return if !$file;

    my ( $name, $path, $suffix ) = fileparse($file);
    return if !-d $path;

    return if !-f $CONF_FILE;

    $ENV{LOGFILENAME} = $file;
    return $CONF_FILE;
  }

=head3 _keep_after_time

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

=head3 _get_save_seconds

Return to number of seconds to save a log file. Converts the figure returned by
get_save_days.

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

Return the number of days to save a log file. Defaults to 30.

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

=head3 get_log_dir

=cut

  #*****************************************************************************
  sub get_log_dir

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

=head3 get_log_file_name

Return the name of the open log file. If a parameter is provided then the path is
returned as well.

=cut

  #*****************************************************************************
  sub get_log_file_name

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
}
