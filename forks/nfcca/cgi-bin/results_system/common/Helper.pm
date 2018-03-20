package Helper;

use strict;
use warnings;
use Carp;
use ResultsSystem;

use parent qw/Exporter/;

our @EXPORT_OK = qw/get_config get_logger get_factory/;

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

  my $file = get_system_full_filename();

  return get_factory()->get_configuration;
}

sub get_logger {
  return get_factory()->get_screen_logger;
}

sub get_factory {
  my $rs = ResultsSystem->new();
  $rs->get_starter->start( get_system_full_filename() );
  return $rs->get_factory;
}

sub get_system_full_filename {
  if ( !( $ARGV[0] || $ENV{NFCCA_CONFIG} ) ) {
    croak "Need a filename in ARGV. <"
      . ( $ARGV[0] || "" )
      . "> or NFCCA_CONFIG must be set. <"
      . ( $ENV{NFCCA_CONFIG} || "" ) . ">";
  }
  my $file = $ARGV[0] || $ENV{NFCCA_CONFIG};
  return $file;
}

1;
