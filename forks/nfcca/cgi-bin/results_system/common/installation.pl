#! /usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Carp;

=head1 installation

Script to the the automation of releases.

perl installation.pl [OPTION]

--mirror L<Copy the remote file to the local machine|/mirror>

--release L<Copy the local files to the remote machine|/release>

--rollback L<Undo the last rollforward|/rollback>

--rollforward L<Move the files for the staging directory prior to release|/rollforward>

=cut

=head2 Minor options

These options have default values and are normally only needed during testing.

--remote_doman The domain to be mirrored. newforestcricket.co.uk

--mirror_base Local directory for mirrored files. /home/duncan/nfcca_mirror

--passwd Password for remote domain. Overrides $ENV{NFCCA_PASSWD}.

--remote_user User for remote domain. newforestcricket.co.uk

=cut

my $options = {};
GetOptions(
  $options,      "mirror",          "release",       "rollback",
  "rollforward", "remote_domain:s", "mirror_base:s", "passwd:s",
  "remote_user:s"
) || croak "Invalid options";

my $NFCCA;
my $MIRROR;
my $LAST;
my $CURRENT;
my $NEXT;
my $NFCCA_PASSWD;
my $RSYNC;
my $RSYNC_TREE;
my $NFCCA_USER;

=head2 setup_globals

=cut

sub setup_globals {
  my $options = shift;
  $NFCCA        = $options->{remote_domain} || "newforestcricket.co.uk";
  $MIRROR       = $options->{mirror_base}   || "/home/duncan/nfcca_mirror";
  $NFCCA_PASSWD = $options->{passwd}        || $ENV{NFCCA_PASSWD};
  $NFCCA_USER   = $options->{remote_user}   || "newforestcricket.co.uk";

  $LAST    = "$MIRROR/last";
  $CURRENT = "$MIRROR/current";
  $NEXT    = "$MIRROR/next";

  croak "NFCCA_PASSWD is not set." if !$NFCCA_PASSWD;

  $RSYNC      = "rsync --rsh \"/usr/bin/sshpass -p $NFCCA_PASSWD ssh -l $NFCCA_USER\"";
  $RSYNC_TREE = "$RSYNC -rt --delete";
  1;
}

=head2 Local directory structure

  duncan@debian2:~$ tree -d -L 2 nfcca_mirror/
  nfcca_mirror/
  |-- current
  |   |-- cgi-bin
  |   |-- public_html
  |   `-- results_system
  |-- last
  |   |-- cgi-bin
  |   |-- public_html
  |   `-- results_system
  `-- next

=cut

=head2 Remote directory structure

  [newforestcricket.co.uk@sharedssh0 ~]$ pwd
  /home/cluster-sites/29/newforestcricket.co.uk/
  [newforestcricket.co.uk@sharedssh0 ~]$ ls results_system
  fixtures  logs
  [newforestcricket.co.uk@sharedssh0 ~]$
  
  [newforestcricket.co.uk@sharedssh0 cgi-bin]$ pwd
  /home/cluster-sites/29/newforestcricket.co.uk/cgi-bin
  [newforestcricket.co.uk@sharedssh0 cgi-bin]$ ls
  results_system
  
  [newforestcricket.co.uk@sharedssh0 results_system]$ ls
  common  custom
  [newforestcricket.co.uk@sharedssh0 results_system]$

=cut

=head2 Authentication

The password is read from the environment variable NFCCA_PASSWD.

=cut

=head2 Private functions

=cut

=head3 sync_tree

=cut

sub sync_tree {
  my ( $from, $to ) = @_;
  my $ok = undef;

  for ( my $x = 0; $x < 10; $x++ ) {
    my $res = system("$RSYNC_TREE $from $to");
    $ok = !$res;
    print $ok ? "\n$from complete\n" : "\n$from failed " . ( $x + 1 ) . " times\n";
    last if $ok;
    sleep 5;
  }
  return $ok;
}

=head3 mirror

perl installation.pl --mirror

Use rsync to copy any changes in the results_system, cgi-bin or public_html directory structures
to the corresponding directories on the local machine.

Any files on the local machine which do not exist on the remote machine are deleted.

=cut

sub mirror {

  sync_tree( "$CURRENT/*", "$LAST" ) || croak "Unable to sync_tree $CURRENT";

  sync_tree( "$NFCCA:results_system/", "$CURRENT" )
    || croak "Unable to sync_tree: $NFCCA:results_system";
  sync_tree( "$NFCCA:cgi-bin/", "$CURRENT" ) || croak "Unable to sync_tree: $NFCCA:cgi-bin";
  sync_tree( "$NFCCA:public_html/results_system/", "$CURRENT/public_html/results_system" )
    || croak "Unable to sync_tree: $NFCCA:cgi-bin";

  return 1;
}

=head3 release

perl installation.pl --release

Use rsync to copy any changes in the cgi-bin and public_html directories on to the remote machine.

Note that the results_system directory structures which contains the logs and the fixtures is not copied.
There is deemed to be to much risk of accidentally over-writing changes on the remote machine.

Any files on the remote machine which do not exist locally are deleted.

=cut

sub release {

  #sync_tree( "$CURRENT/results_system", "$NFCCA:results_system" )
  #|| croak "Unable to sync_tree: $CURRENT/results_system";
  sync_tree( "$CURRENT/cgi-bin/", "$NFCCA:cgi-bin" )
    || croak "Unable to sync_tree: $CURRENT/cgi-bin";

  sync_tree( "$CURRENT/public_html/results_system/common/", "$NFCCA:public_html/results_system" )
    || croak "Unable to sync_tree: $CURRENT/public_html/results_system/common";

  sync_tree(
    "$CURRENT/public_html/results_system/custom/nfcca/*.css",
    "$NFCCA:public_html/results_system/custom/nfcca"
  ) || croak "Unable to sync_tree: $CURRENT/public_html/results_system/custom/nfcca css";

  sync_tree(
    "$CURRENT/public_html/results_system/custom/nfcca/*.htm",
    "$NFCCA:public_html/results_system/custom/nfcca"
  ) || croak "Unable to sync_tree: $CURRENT/public_html/results_system/custom/nfcca htm";

  # Too dangerous to sync fixtures and definately don't want to sync logs.
  #sync_tree(
  #  "$CURRENT/public_html/results_system/fixtures/*.csv",
  #  "$NFCCA:public_html/results_system/fixtures"
  #) || croak "Unable to sync_tree: $CURRENT/cgi-bin";

  return 1;
}

=head3 rollback

perl installation.pl --rollback

Use rsync to copy changes from the current directory tree to the next directory and the last directory
tree to the current directory tree.

Intended to undo a rollforward.

=cut

sub rollback {
  sync_tree( $CURRENT . '/', $NEXT )    || croak "Unable to sync_tree rollback $CURRENT";
  sync_tree( $LAST . '/',    $CURRENT ) || croak "Unable to sync_tree rollback $LAST";
  return 1;
}

=head3 rollforward

perl installation.pl --rollforward

Use rsync to copy changes from the current directory tree to the last directory tree
and from the next directory tree to the current tree.

Assumes that the "next" directory contains code which is about to be released. Assumes
that it is wise to be a backup in "last"!

=cut

sub rollforward {
  sync_tree( $CURRENT . '/', $LAST )    || croak "Unable to sync_tree rollback $CURRENT";
  sync_tree( $NEXT . '/',    $CURRENT ) || croak "Unable to sync_tree rollback";
  return 1;
}

=head3 main

Examine the script options and call mirror, release, rollback or rollforward as appropriate.

Dies if the environment NFCCA_PASSWD, which should contain the password, is not set.

Dies if more than one option is present.

=cut

sub main {
  my $opts = shift;

  setup_globals($opts);

  my $actions = {
    mirror      => \&mirror,
    release     => \&release,
    rollback    => \&rollback,
    rollforward => \&rollforward
  };

  for my $o (qw/ mirror release rollback rollforward/) {
    if ( $opts->{$o} ) {
      $actions->{$o}->();
      last;
    }
  }

  print "\nDone\n";
  return 1;
}

main($options) if !caller;

1;
