#! /usr/bin/perl

use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use Carp;

=head1 installation

Script to the the automation of realases.

perl installation.pl [OPTION]

--mirror L<Copy the remote file to the local machine|/mirror>

--release L<Copy the local files to the remote machine|/release>

--rollback L<Undo the last rollforward|/rollback>

--rollforward L<Move the files for the staging directory prior to release|/rollforward>

=cut

my $options = {};
GetOptions( $options, "mirror", "release", "rollback", "rollforward" ) || croak "Invalid options";

my $NFCCA   = "newforestcricket.co.uk";
my $MIRROR  = "/home/duncan/nfcca_mirror";
my $LAST    = "$MIRROR/last";
my $CURRENT = "$MIRROR/current";
my $NEXT    = "$MIRROR/next";

my $RSYNC =
  "rsync --rsh \"/usr/bin/sshpass -p $ENV{NFCCA_PASSWD} ssh -l newforestcricket.co.uk\"";

my $RSYNC_TREE = "$RSYNC -rt --delete";

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

  sync_tree( "$NFCCA:results_system", "$CURRENT" )
    || croak "Unable to sync_tree: $NFCCA:results_system";
  sync_tree( "$NFCCA:cgi-bin", "$CURRENT" ) || croak "Unable to sync_tree: $NFCCA:cgi-bin";
  sync_tree( "$NFCCA:public_html/results_system", "$CURRENT/public_html/results_system" )
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

  sync_tree( "$CURRENT/results_system", "$NFCCA:results_system" )
    || croak "Unable to sync_tree: $CURRENT/results_system";
  sync_tree( "$CURRENT/cgi-bin", "$NFCCA:cgi-bin" )
    || croak "Unable to sync_tree: $CURRENT/cgi-bin";

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
  sync_tree( $CURRENT . '/*', $NEXT )    || croak "Unable to sync_tree rollback $CURRENT";
  sync_tree( $LAST . '/*',    $CURRENT ) || croak "Unable to sync_tree rollback $LAST";
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
  sync_tree( $CURRENT . '/*', $LAST )    || croak "Unable to sync_tree rollback $CURRENT";
  sync_tree( $NEXT . '/*',    $CURRENT ) || croak "Unable to sync_tree rollback";
  return 1;
}

=head3 main

Examine the script options and call mirror, release, rollback or rollforward as appropriate.

Dies if the environment NFCCA_PASSWD, which should contain the password, is not set.

Dies if more than one option is present.

=cut

sub main {
  my $opts = shift;

  croak "NFCCA_PASSWD is not set." if !$ENV{NFCCA_PASSWD};

  my $num_opts = scalar( keys %$opts );
  croak "Only one option at a time is allowed" if $num_opts > 1;

  mirror()
    if $opts->{mirror};

  release() if $opts->{release};

  rollback() if $opts->{rollback};

  rollforward() if $opts->{rollforward};

  print "\nDone\n";
  return 1;
}

main($options) if !caller;
