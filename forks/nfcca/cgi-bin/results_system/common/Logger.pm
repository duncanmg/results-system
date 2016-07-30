
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

  our @ISA = qw/ Exporter /;

  our @EXPORT_OK = qw/ get_logger /;

  my $conf = {
    "log4perl.rootLogger"             => "INFO , Screen",
    "log4perl.logger.xxxx"            => "INFO, Screen",
    "log4perl.appender.Screen"        => "Log::Log4perl::Appender::Screen",
    "log4perl.appender.Screen.stderr" => 1,
    "log4perl.appender.Screen.layout" => "Log::Log4perl::Layout::PatternLayout",
    "log4perl.appender.Screen.layout.ConversionPattern" =>
      "[%d{dd/MMM/yyyy:HH:mm:ss}] %c %p %F{1} %M %L - %m%n"
  };

=head2 get_logger

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

    if ($file) {
      $conf                                             = {};
      $conf->{"log4perl.rootLogger"}                    = "INFO , LOGFILE";
      $conf->{"log4perl.category.ResultsConfiguration"} = "INFO , LOGFILE";
      $conf->{"log4perl.category.Fixtures"}             = "INFO , LOGFILE";
      $conf->{"log4perl.category.WeekFixtures"}         = "INFO , LOGFILE";
      $conf->{"log4perl.category.WeekData"}             = "INFO , LOGFILE";
      $conf->{"log4perl.appender.LOGFILE"}              = "Log::Log4perl::Appender::File";
      $conf->{"log4perl.appender.LOGFILE.filename"}     = $file;
      $conf->{"log4perl.appender.LOGFILE.mode"}         = "append";
      $conf->{"log4perl.appender.LOGFILE.layout"}       = "Log::Log4perl::Layout::PatternLayout";
      $conf->{"log4perl.appender.LOGFILE.layout.ConversionPattern"} =
        "[%d{dd/MMM/yyyy:HH:mm:ss}] %c %p %F{1} %M %L - %m%n";

      my $conf_file = "./logger.conf";
      if ( -f $conf_file ) {
        $ENV{LOGFILENAME} = $file;
        $conf = $conf_file;
      }
    }

    Log::Log4perl::init($conf);

    my $logger = Log::Log4perl::get_logger($category);

    return $logger;

  }

  1;

}

