package Helper;

use strict;
use warnings;
use ResultsConfiguration;
use Logger;

use parent qw/Exporter/;

our @EXPORT_OK = qw/get_config get_logger/;

=head1 Helper

Test helpers.

  use Helper qw/get_config/;

=cut

=head2

Read the configuration file contained in $ARGV[0] or, if $ARGV[0] is false,
the environment variable NFCCA_CONFIG.

Die if neither is present.

=cut

sub get_config {

  if ( !( $ARGV[0] || $ENV{NFCCA_CONFIG} ) ) {
    die "Need a filename in ARGV. <"
      . ( $ARGV[0] || "" )
      . "> or NFCCA_CONFIG must be set. <"
      . ( $ENV{NFCCA_CONFIG} || "" ) . ">";
  }
  my $file = $ARGV[0] || $ENV{NFCCA_CONFIG};

  my $config =
    ResultsConfiguration->new( -full_filename => $file, -logger => Logger->new()->get_logger );
  die "Unable to create ResultsConfiguration object" if !$config;
  die "Unable to read file" if $config->read_file;

  return $config;
}

sub get_logger {
  my $config = shift;
  return Logger->new( -log_dir => ( $config->get_path( -log_dir => 1 ) ) );
}

1;
