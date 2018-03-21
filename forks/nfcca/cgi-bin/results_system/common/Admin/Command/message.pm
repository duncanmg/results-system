## no critic (NamingConventions::Capitalization)

package Admin::Command::message;

use strict;
use warnings;
use Admin -command;

sub execute {
  print "Hello\n";
  return 1;
}

1;

