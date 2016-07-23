#! /usr/bin/perl

{

  package FixturesIndex;

  use strict;
  use CGI;

  use Fixtures;
  use ResultsConfiguration;
  use Data::Dumper;

  our @ISA;
  unshift @ISA, "Parent";

  #***************************************
  sub new {

    #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    $self->initialise( \%args );
    $self->logger->debug("FixturesIndex object created.");

    return $self;
  }

  # *********************************************************
  sub get_html_filename {

    # *********************************************************
    my $self = shift;
    my $file = shift;    # csv_file
    my $line;

    $file =~ s/\.csv$/\.htm/;

    return $file;
  }

  # *********************************************************
  sub output_html {

    # *********************************************************
    my $self = shift;
    my $err  = 0;

    my $q     = $self->get_query;
    my $c     = $self->get_configuration;
    my @names = $c->get_menu_names;
    my ( $line, $l );
    $self->logger->debug( scalar(@names) . " divisions to be listed." );

    $line =
      $line
      . $q->h1(
      $c->get_descriptors( -title => "Y" ) . " " . $c->get_descriptors( -season => "Y" ) )
      . "\n";

    $line = $line . "<h2>Index of Fixtures</h2>\n";
    $line = $line . $self->return_to_link("-fixtures_index") . "\n";

    my $d = $c->get_path( -table_dir => "Y" );

    $self->logger->debug(Dumper @names);

    foreach my $division (@names) {

      eval {
	      $self->logger->warn('Path is hardcoded!');
        my $link = "/results_system.pl?sysyem=nfcca&page=fixtures_index&division=$division->{csv_file}";
        $l = $l . $q->li( $q->a( { -href => $link }, $division->{menu_name} ) );
      };
      if ($@) {
        $self->logger->error( "Problem processing " . $division->{menu_name} );
        $self->logger->error($@);
        $err = 1;
      }
      if ( $err != 0 ) {
        last;
      }
    }
    $line = $line . $q->ul($l);
    return ( $err, $line );

  }

  1;

}

