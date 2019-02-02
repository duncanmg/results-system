package Helper;

use strict;
use warnings;
use Carp;
use ResultsSystem;

use parent qw/Exporter/;

our @EXPORT_OK =
  qw/get_config get_logger get_factory get_example_csv_full_filename get_example_results_full_filename/;

=head1 NAME

Helper

=head1 SYNOPSIS

Test helpers.

  use Helper qw/get_factory/;

  my $factory;
  ok( $factory = get_factory, "Got a factory object.");

=cut

=head1 DESCRIPTION

Provides a series of functions which assists the writing of test scripts for the results system.

The most commonly used one is get_factory which returns new factory object on each call.

The documentation on get_system explain which configuration file is used.

=head1 INHERITS FROM

Nothing, this is not an object.

=head1 EXTERNAL (PUBLIC) METHODS

N/A

=head1 INTERNAL (PRIVATE) METHODS

N/A

=head1 EXPORTED FUNCTIONS

=cut

=head2 get_factory

Returns a new factory object on each call.

=cut

sub get_factory {
  my $rs = ResultsSystem->new();
  $rs->get_starter->start( get_system() );
  return $rs->get_factory;
}

=head2 get_config

Reads the configuration file contained in $ARGV[0] or, if $ARGV[0] is false,
the environment variable NFCCA_CONFIG.

Die if neither is present.

=cut

sub get_config {

  my $file = get_system();

  return get_factory()->get_configuration;
}

=head2 get_logger

=cut

sub get_logger {
  return get_factory()->get_screen_logger;
}

=head2 get_example_csv_full_filename

=cut

sub get_example_csv_full_filename {
  my $c = get_factory()->get_configuration;
  $c->set_csv_file('U9N.csv');
  return $c->get_csv_full_filename;
}

=head2 get_example_results_full_filename

=cut

sub get_example_results_full_filename {
  my $c = get_factory()->get_configuration;
  $c->set_csv_file('U9N.csv');
  $c->set_matchdate('8-May');
  return $c->get_results_full_filename;
}

=head1 NON-EXPORTED FUNCTIONS

=cut

=head2 get_system

Reads the system from $ARGV[0] or, if that is not set,
from the environment variable $NFCCA_CONFIG.

  NFCCA_TESTDIR=`pwd` perl  -I lib t/ResultsSystem/View/Week/Results.t nfcca

or

  NFCCA_TESTDIR=`pwd` NFCCA_CONFIG=nfcca \
    perl  -I lib t/ResultsSystem/View/Week/Results.t

Returns whatever it finds, which should be the system name eg nfcca.

=cut

sub get_system {
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
