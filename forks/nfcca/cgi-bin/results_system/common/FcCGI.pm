package FcCGI;

=head1 FcCGI

Subclass of CGI.

Only the start_html method is over-ridden, it can now return an HTML5 doctype.

=cut

use strict;
use warnings;
use CGI qw/meta/;
use Exporter;

our @ISA = qw/CGI Exporter/;

our @EXPORT_OK = qw/meta/;

=head2 start_html

Passes all parameters on to CGI except the new -html5 parameter.

If -html5 is true then the normal CGI output is modified to replace the DOCTYPE
with one for HTML5.

=cut

sub start_html {
  my $self  = shift;
  my %args  = @_;
  my $html5 = $args{'-html5'};
  delete $args{'-html5'};
  my $out = $self->SUPER::start_html(%args);
  if ($html5) {
    $out =~ s/^.*<head>/<head>/gxms;
    $out = '<!DOCTYPE html' . '>' . "\n" . $out;
  }
  return $out;
}

1;
