
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

=head3 default_conf

Default configuration

=cut

  sub default_conf {
    return {
      "log4perl.rootLogger"             => "INFO , Screen",
      "log4perl.logger.xxxx"            => "INFO, Screen",
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

file: File messages will be logged to.

If $file is undefined then messages are logged to the screen.

If file is provided then it tries to read the rest of the configuration from a file called logger.conf in the current directory.

If that doesn't exist then a set of defaults are used.

=cut

  sub get_logger {
    my ( $category, $file ) = validate_pos( @_, 1, 0 );

    $category = 'Default' if !$category;
    my $conf = get_conf($file);

    Log::Log4perl::init($conf);

    my $logger = Log::Log4perl::get_logger($category);

    return $logger;

  }

  sub get_conf {
    my $file = shift;

    return default_conf() if !$file;

    my ( $name, $path, $suffix ) = fileparse($file);
    return default_conf() if !-d $path;

    return conf_with_logfile($file) if !-f $CONF_FILE;

    $ENV{LOGFILENAME} = $file;
    return $CONF_FILE;
  }

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
      $self->{logger} = Logger::get_logger( $class, $self->logfile_name($dir) );

    }
    return $self->{logger};
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

    my $d = $self->get_log_dir;
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
      $self->logger->error( "Log directory does not exist. " . $self->get_log_dir );
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
}    # End package Fcutils
