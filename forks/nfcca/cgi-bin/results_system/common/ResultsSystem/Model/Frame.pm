package ResultsSystem::Model::Frame;

use strict;
use warnings;

sub new {
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  $self->{logger} = $args->{-logger}        if $args->{-logger};
  $self->{conf}   = $args->{-configuration} if $args->{-configuration};
  return $self;
}

sub logger {
  my $self = shift;
  return $self->{logger};
}

=head2 run

Write the HTML for a frame based on common/results.htm in the htdocs
directory to the standard output.

It changes the paths and the system information, but nothing else.

=cut

# ******************************************************
# This function reads the frame page, results.htm. It substitutes
# in the correct path and system information for the pages and
# then sends it to the output. It give the frame an expiry time of
# two days.
# ******************************************************
sub run {

  # ******************************************************
  my $self = shift;
  my %args = (@_);
  my $c    = $self->{conf};
  my $err  = 0;
  my @file_lines;

  my $data = {};

  my $root = $c->get_path( -root => "Y" );

  my $dir = $c->get_path( -htdocs_full => 'Y' );

  my $cgi_path = $c->get_path( "-cgi_dir" => "Y", -allow_not_exists => 1 );
  $cgi_path = "$cgi_path/common";
  if ( !-d "$root$cgi_path" ) {
    $self->logger->error("output_frame() $root$cgi_path does not exist.");
    $err = 1;
  }

  $cgi_path = $cgi_path . "/results_system.pl?system=" . $c->get_system . "&page=";

  $data->{MENU_PAGE}  = $cgi_path . "menu";
  $data->{BLANK_PAGE} = $cgi_path . "blank";

  return $data;
}

1;
