use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;

my $opts = {};
GetOptions( $opts, "mirror", "release", "rollback", "rollforward" ) || die "Invalid options";

my $NFCCA   = "newforestcricket.co.uk";
my $MIRROR  = "/home/duncan/nfcca_mirror";
my $LAST    = "$MIRROR/last";
my $CURRENT = "$MIRROR/current";
my $NEXT    = "$MIRROR/next";

my $RSYNC =
  "rsync --rsh \"/usr/bin/sshpass -p $ENV{NFCCA_PASSWD} ssh -l newforestcricket.co.uk\"";

my $RSYNC_TREE = "$RSYNC -rt --delete";

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

sub mirror {

  sync_tree( "$CURRENT/*", "$LAST" ) || die "Unable to sync_tree $CURRENT";

  sync_tree( "$NFCCA:results_system", "$CURRENT" )
    || die "Unable to sync_tree: $NFCCA:results_system";
  sync_tree( "$NFCCA:cgi-bin", "$CURRENT" ) || die "Unable to sync_tree: $NFCCA:cgi-bin";
  sync_tree( "$NFCCA:public_html/results_system", "$CURRENT/public_html/results_system" )
    || die "Unable to sync_tree: $NFCCA:cgi-bin";

  return 1;
}

sub release {

  sync_tree( "$CURRENT/results_system", "$NFCCA:results_system" )
    || die "Unable to sync_tree: $CURRENT/results_system";
  sync_tree( "$CURRENT/cgi-bin", "$NFCCA:cgi-bin" )
    || die "Unable to sync_tree: $CURRENT/cgi-bin";

  # Too dangerous to sync fixtures and definately don't want to sync logs.
  #sync_tree(
  #  "$CURRENT/public_html/results_system/fixtures/*.csv",
  #  "$NFCCA:public_html/results_system/fixtures"
  #) || die "Unable to sync_tree: $CURRENT/cgi-bin";

  return 1;
}

sub rollback {
  sync_tree( $CURRENT, $NEXT )    || die "Unable to sync_tree rollback $CURRENT";
  sync_tree( $LAST,    $CURRENT ) || die "Unable to sync_tree rollback $LAST";
}

sub rollforward {
  sync_tree( $CURRENT, $LAST )    || die "Unable to sync_tree rollback $CURRENT";
  sync_tree( $NEXT,    $CURRENT ) || die "Unable to sync_tree rollback";
}

sub main {
  my $opts = shift;

  die "NFCCA_PASSWD is not set." if !$ENV{NFCCA_PASSWD};

  my $num_opts = scalar( keys %$opts );
  die "Only one option at a time is allowed" if $num_opts > 1;

  mirror()
    if $opts->{mirror};

  release() if $opts->{release};

  rollback() if $opts->{rollback};

  rollforward() if $opts->{rollforward};

  print "\nDone\n";
}

main($opts) if !caller;
