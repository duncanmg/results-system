
=head1 Logger

Very simple module to set up log4perl. Logit.pm seems to be aimed at batch files, this is aimed at CGI scripts.

This sends formatted messages to the STDERR on the assumption that they will end up in the Zeus logs.

Debug and info level messages aren't printed on production boxes. Uses WhereAmI to decide which box it is on.

 use Logger;
 my $log = get_mlogger( __PACKAGE__ );
 $log->debug("Debug message");

 [05/May/2010:15:08:44] DEBUG main:: log4perl.pl (10) - Debug message
 [05/May/2010:15:08:44] INFO main:: log4perl.pl (11) - Info message
 [05/May/2010:15:08:44] WARN main:: log4perl.pl (12) - Warn message
 [05/May/2010:15:08:44] ERROR main:: log4perl.pl (13) - Error message

Not sure what will happen if Logit and Mlog4perl are used in the same script. Will the configurations conflict? Better test it
if you want to use them together.

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

  our @EXPORT_OK = qw/ get_mlogger /;

  my $conf = {
    "log4perl.rootLogger"             => "DEBUG , Screen",
    "log4perl.logger.xxxx"            => "INFO, Screen",
    "log4perl.appender.Screen"        => "Log::Log4perl::Appender::Screen",
    "log4perl.appender.Screen.stderr" => 1,
    "log4perl.appender.Screen.layout" => "Log::Log4perl::Layout::PatternLayout",
    "log4perl.appender.Screen.layout.ConversionPattern" =>
      "[%d{dd/MMM/yyyy:HH:mm:ss}] %c %p %F{1} %M %L - %m%n"
  };

  sub get_logger {
    my ( $category, $file ) = validate_pos( @_, 1, 0 );

    $category = 'Default' if !$category;

    # $file = "/tmp/tmp.log";
    if ($file) {
      $conf                                         = {};
      $conf->{"log4perl.rootLogger"}                = "DEBUG , LOGFILE";
      $conf->{"log4perl.appender.LOGFILE"}          = "Log::Log4perl::Appender::File";
      $conf->{"log4perl.appender.LOGFILE.filename"} = $file;
      $conf->{"log4perl.appender.LOGFILE.mode"}     = "append";
      $conf->{"log4perl.appender.LOGFILE.layout"}   = "Log::Log4perl::Layout::PatternLayout";
      $conf->{"log4perl.appender.LOGFILE.layout.ConversionPattern"} =
        "[%d{dd/MMM/yyyy:HH:mm:ss}] %c %p %F{1} %M %L - %m%n";
    }

    Log::Log4perl::init($conf);

    my $logger = Log::Log4perl::get_logger($category);

    return $logger;

  }

  1;

}

