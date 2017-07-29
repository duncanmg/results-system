#! /usr/bin/perl

{

  package TablesIndex;

  use strict;
  use CGI;

  use Fixtures;
  use ResultsConfiguration;

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
    $self->logger->debug("TablesIndex object created.");

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

    $line = $line . "<h2>Index of League Tables</h2>\n";
    $line = $line . $self->return_to_link("-tables_index") . "\n";

    my $d = $c->get_path( -table_dir => "Y", -allow_not_exists => 1 );

    foreach my $division (@names) {

      eval {
        my $link = "$d/" . $self->get_html_filename( $division->{csv_file} );
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

