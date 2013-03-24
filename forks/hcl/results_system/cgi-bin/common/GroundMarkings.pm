package GroundMarkings;

use strict;
use warnings;

sub new {
  my $class = shift;
  my $self = {};
  bless $self, $class;
  return $self;
}

sub labels {
  my $self = shift;
  return qw/ pitch outfield pavilion /;
}
 
sub headings {
  my $self = shift;
  print STDERR "headings YYYYYYYYYYYYYYYYYYYYYYYYYYYYYY\n";
  return "<th>Pitch Marks</th><th>Outfield Marks</th><th>Pavilion</th>";
}

sub cells {
  my ( $self, $div ) = @_;
  my $line = "";
  foreach my $gm ( $self->labels ) {
    $line .= qq!<td><select name="$gm" id="$gm">
                <option value="0">Please select</option>
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
                <option value="4">4</option>
                <option value="5">5</option>
                </select></td>!;
    $line .= "\n";
  }
  return $line;
}

1;

