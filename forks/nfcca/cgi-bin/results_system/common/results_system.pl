#! /usr/bin/perl

=head1 Name

results_system.pl

=cut

=head1 Description

The script is part of the Results System and is designed to be called from a browser. It is most commonly
called using GET parameters.

Examples:

/cgi-bin/results_system/dev/common/results_system.pl?page=frame&system=sehca

/cgi-bin/results_system/dev/common/results_system.pl?system=sehca&page=results_index

/cgi-bin/results_system/dev/common/results_system.pl?system=sehca&page=tables_index

=over 5

=item * system

The results system which is to be called. The system can support several independent systems within the same directory structure
and using the same code base. eg HCL for Hampshire Cricket League and SEHCA for South East Hampshire Cricket Association.

This parameter is mandatory.

=item * page

The HTML page which the script should output. This parameter is mandatory.

=over 5

=item * L<results_index|ResultsIndex>

=item * L<tables_index|TablesIndex>

=item * frame

=item * L<menu|Menu>

=item * L<week_fixtures|WeekFixtures>

=item * L<week_results|WeekFixtures>

=item * save_results

=item * L<fixtures_index|FixturesIndex>

=item * L<fixture_list|FixtureList>

=item * blank

=back

=back

=cut

BEGIN {
  unshift @INC, '/home/hantscl/perl5/lib/perl5/x86_64-linux-thread-multi',
    '/home/hantscl/perl5/lib/perl5';
}

# use local::lib;
use strict;
use CGI;
use Slurp;
use Params::Validate qw/:all/;

use Fcutils2;

use Menu;
use WeekFixtures;
use LeagueTable;
use ResultsIndex;
use TablesIndex;
use GroundMarkings;
use FixtureList;
use FixturesIndex;
use Data::Dumper;

my $logger;

=head1 Functions

=cut

=head2 output_frame

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
sub output_frame {

  # ******************************************************
  my %args = (@_);
  my $q    = $args{-query};
  my $c    = $args{-config};
  my $u    = $args{-util};
  my $err  = 0;
  my $line;
  my @file_lines;

  my $root = $c->get_path( -root => "Y" );

  my $dir = $c->get_path( -htdocs_full => 'Y' );
  my $ff = "$dir/common/results.htm";

  if ( !-f $ff ) {
    $u->logger->debug("$ff does not exist.");
    $err = 1;
  }

  my $cgi_path = $c->get_path( "-cgi_dir" => "Y", -allow_not_exists => 1 );
  $cgi_path = "$cgi_path/common";
  if ( !-d "$root$cgi_path" ) {
    $u->logger->debug("output_frame() $root$cgi_path does not exist.");
    $err = 1;
  }

  if ( $err == 0 ) {
    @file_lines = slurp($ff);
    $u->logger->debug( scalar(@file_lines) . " lines read from $ff" );
    $cgi_path = $cgi_path . "/results_system.pl?system=" . $q->param("system") . "&page=";
    foreach my $f (@file_lines) {
      my $p = "menu";
      $f =~ s/MENU_PAGE/$cgi_path$p/;
      $p = "blank";
      $f =~ s/BLANK_PAGE/$cgi_path$p/;
      $line = $line . $f;
    }
  }

  print $q->header( -expires => "+2d" );
  print $line;

  # $u->logger->debug( $line);
  return $err;
}

=head2 output_page

Write the HTML for the page to the standard output.

In most cases, this is done by calling the output_html method of the appropriate object.
The exceptions are "save_results" and "blank".

"save_results" calls WeekFixtures to save the results and LeagueTable to regenerate the
league tables.

"blank" is handled in the function L</output_frame>.
=cut

# ******************************************************
sub output_page {

  # ******************************************************
  my %args = (@_);
  my $q    = $args{-query};
  my $c    = $args{-config};
  my $u    = $args{-util};
  my $page = $args{-page};
  my $err  = 0;
  my $line;

  print $q->header( -expires => "+15m" );
  my @styles = $c->get_stylesheets;
  print $q->start_html(
    -title => "Results System: " . $page,
    -style => $c->get_path( -htdocs => "Y", -allow_not_exists => "Y" ) . "/custom/" . $styles[0]
  );
  $u->logger->debug("page=$page");

  my $save_results = sub {
    my $obj = WeekFixtures->new( -query => $q, -config => $c );
    ( $err, $line ) = $obj->save_results( -save_html => 1 );
    print $line . "\n";
    if ( $err == 0 ) {
      my $l = LeagueTable->new( -query => $q, -config => $c );
      $err = $l->create_league_table_file;
    }
    return $err;
  };

  eval {

    my $dispatch_table = {
      "menu"          => sub { output_html( "Menu", { -query => $q, -config => $c }, {} ); },
      "week_fixtures" => sub {
        output_html( "WeekFixtures", { -query => $q, -config => $c }, { "-form" => 1 } );
      },
      "week_results" =>
        sub { output_html( "WeekFixtures", { -query => $q, -config => $c }, {} ); },
      "save_results" => sub { $save_results->(); },
      "results_index" =>
        sub { output_html( "ResultsIndex", { -query => $q, -config => $c }, {} ); },
      "tables_index" =>
        sub { output_html( "TablesIndex", { -query => $q, -config => $c }, {} ); },

      "fixtures_index" =>
        sub { output_html( "FixturesIndex", { -query => $q, -config => $c }, {} ); },
      "fixture_list" =>
        sub { output_html( "FixtureList", { -query => $q, -config => $c }, {} ); },
      "blank" => sub { $u->logger->debug("Blank page called"); },
    };

    $err =
        $dispatch_table->{$page}
      ? $dispatch_table->{$page}->()
      : $u->logger->error( "Page parameter not recognised. " . $page );
  };
  if ($@) {
    $u->logger->debug($@);
    $err = 1;
  }

  # print "err=" . $err . " " . localtime;
  print $q->end_html;

  return $err;
}

=head2 output_html

Helper function called from output_page.

=cut

sub output_html {
  my ( $object, $constructor_args, $method_args ) =
    validate_pos( @_, { type => SCALAR }, { type => HASHREF }, { type => HASHREF } );

  my $obj = $object->new(%$constructor_args);

  my ( $err, $line ) = $obj->output_html(%$method_args);
  if ($line) {
    print $line;
  }
  return $err;
}

=head2 output_csv

Write the HTML for the page to the standard output.

=cut

# ******************************************************
sub output_csv {

  # ******************************************************
  my %args = (@_);
  my $q    = $args{-query};
  my $c    = $args{-config};
  my $u    = $args{-util};
  my $page = $args{-page};
  my $err  = 0;
  my $line;

  $u->logger->debug("page=$page");

  eval {

    if ( $page eq "ground_markings" ) {

      my $p = GroundMarkings->new( -query => $q, -config => $c );
      ( $err, $line ) = $p->output_csv;
      print $line;

    }

    else {
      $u->logger->debug( "Page parameter not recognised. " . $page );
    }

  };
  if ($@) {
    $u->logger->debug($@);
    $err = 1;
  }

  return $err;
}

=head2 main

=cut

# ******************************************************
sub main {

  # ******************************************************
  my $q   = CGI->new();
  my $err = 0;
  my $LOG;
  my $log_file = "results_system";
  my $log_path = "/usr/home/sehca/public_html/sehca_logs";
  my $c;

  # my $line;

  my $u = Fcutils2->new( -append_to_logfile => 'Y', -auto_clean => 'Y' );
  $logger = $u->logger;

  my $system = $q->param("system");
  my $page   = $q->param("page");

  eval {
    my $f = "../custom/$system/$system.ini" if $system;

    # $u->logger->debug("Configuration file <$f> for system <$system>.");
    $c = ResultsConfiguration->new( -full_filename => $f );
    if ( !$c ) {
      $err = 1;
      $u->logger->debug($ResultsConfiguration::create_errmsg);
    }
    $err = $c->read_file;
    if ( $err == 0 ) {
      $log_path = $c->get_path( -log_dir => "Y" );
      $log_file = $c->get_log_stem($system);
    }
  };
  if ($@) {
    print STDERR $@ . "\n";
    $u->logger->debug($@);
    $err = 1;
  }

  if ( $err == 0 ) {
    $err = $u->SetLogDir($log_path);
  }
  if ( $err == 0 ) {
    $u->set_lock_dir($log_path);
  }

  if ( $err == 0 ) {
    $err = $u->OpenLockFile($log_file);
  }
  if ( $err == 0 ) {
    ( $err, $LOG ) = $u->OpenLogFile($log_file);
  }
  if ( $err != 0 ) {
    return $err;
  }

  $u->logger->debug("system=$system page=$page");
  $u->logger->debug( "division="
      . $q->param("division")
      . " matchdate="
      . $q->param("matchdate")
      . " user="
      . $q->param("user") );

  if ( $page eq 'ground_markings' ) {
    $err = output_csv( -query => $q, -config => $c, -util => $u, -page => $page );
  }
  elsif ( $page !~ m/frame/i ) {
    $err = output_page( -query => $q, -config => $c, -util => $u, -page => $page );
  }
  else {
    eval { $err = output_frame( -query => $q, -config => $c, -util => $u, -page => $page ); };
    if ($@) {
      $u->logger->debug($@);
      $err = 1;
    }
  }
  $u->CloseLogFile( $LOG, $err );
  $u->CloseLockFile;

  #
}

my $debug = 0;
my $t;
if ($debug) {

  $t = CGI->new;
  print $t->header;
  print $t->start_html;

  print "Hello\n";

}

eval {

  if ($debug) {
    require Menu;
    require WeekFixtures;
    require LeagueTable;
    require ResultsIndex;
    require TablesIndex;
  }
  main;
};
print "<p>" . $@ . "</p>\n" if $@;

if ($debug) {
  $t->end_html;
}
