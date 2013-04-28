# ************************************************************
#
# Name: Parent.pm
#
# 0.1  - 25 Jun 08 - POD added.
# 0.2  - 27 Jun 08 - _trim() added.
# 0.3  - 27 Jun 08 - use Regexp::Common added.
#
# ************************************************************

=head1 Parent.pm

This package provides the methods which the objects in the results system inherit.

=cut

=head1 Methods

=cut

{

  package Parent;

  use strict;
  use CGI;
  use Regexp::Common;
  use DateTime;
  use Logger;
  use ResultsConfiguration;

  our @ISA;
  unshift @ISA, "Fcwrapper";

  #***************************************
  sub new {

    #***************************************
    my $self = {};
    bless $self;
    shift;
    my %args = (@_);

    if ( $args{-query} ) {
      $self->set_query( $args{-query} );
    }
    else {
      $self->set_query( CGI->new() );
    }

    return $self;
  }

=head2 initialise

This method is called by the constructors of the child modules. It checks for the -query
and -config arguments and process them if they are present. 

If the -query argument is present it looks for the division and matchdate parameters of the query
and calls set_division() and set_week() if necessary.

The -query or -config are not present then default objects are created.

=cut

  #***************************************
  sub initialise {

    #***************************************
    my $self = shift;
    my $ref  = shift;
    my %args = %$ref;

    if ( $args{-query} ) {
      $self->set_query( $args{-query} );
      my $q = $self->get_query;
      if ( $q->param("division") ) {
        $self->set_division( $q->param("division") );
      }
      if ( $q->param("matchdate") ) {
        $self->set_week( $q->param("matchdate") );
      }
    }
    else {
      $self->set_query( CGI->new() );
    }

    if ( $args{-config} ) {
      $self->set_configuration( $args{-config} );
    }
    else {
      my $c = ResultsConfiguration->new();
      if ($c) {
        $c->read_file;
        $self->set_configuration($c);
      }
    }
    $self->logfile_name( $self->get_configuration->get_path( -log_dir => 'Y' ) );

  }

=head2 set_query

Set the CGI object.

=cut

  #***************************************
  sub set_query {

    #***************************************
    my $self = shift;
    $self->{QUERY} = shift;
  }

=head2 get_query

Return the CGI object.

=cut

  #***************************************
  sub get_query {

    #***************************************
    my $self = shift;
    return $self->{QUERY};
  }

=head2 set_configuration

Set the ResultsConfiguration object.

=cut

  #***************************************
  sub set_configuration {

    #***************************************
    my $self = shift;
    $self->{CONFIGURATION} = shift;
  }

=head2 get_configuration

Return the ResultsConfiguration object.

=cut

  #***************************************
  sub get_configuration {

    #***************************************
    my $self = shift;
    return $self->{CONFIGURATION};
  }

=head2 set_division

Set the csv filename for the division.

=cut

  #***************************************
  sub set_division {

    #***************************************
    my $self = shift;
    $self->{DIVISION} = shift;
  }

=head2 get_division

Return the name of the csv file for the division

=cut

  #***************************************
  # Holds the name of the csv file.
  #***************************************
  sub get_division {

    #***************************************
    my $self = shift;
    return $self->{DIVISION};
  }

=head2 set_week

Set the match date.

=cut

  #***************************************
  sub set_week {

    #***************************************
    my $self = shift;
    $self->{WEEK} = shift;
  }

=head2 get_week

Return the match date.

=cut

  #***************************************
  sub get_week {

    #***************************************
    my $self = shift;
    return $self->{WEEK};
  }

=head2 get_filename

Returns the .dat filename for the week.

=cut

  #***************************************
  sub get_filename {

    #***************************************
    my $self = shift;
    my $err  = 0;
    my $f;
    my $w = $self->get_week;
    my $d = $self->get_division;

    if ( !$w ) {
      $self->logger->debug("Week undefined");
      $err = 1;
    }
    if ( !$d ) {
      $self->logger->debug("Division undefined");
      $err = 1;
    }
    if ( $err == 0 ) {
      $d =~ s/\..*$//g;    # Remove extension
      $f = $d . "_" . $w . ".dat";
      $f =~ s/\s//g;
    }
    if ( $err == 0 ) {
      return $f;
    }
  }

=head2 get_full_filename

Returns the .dat filename for the week complete with the csv path.

=cut

  #***************************************
  sub get_full_filename {

    #***************************************
    my $self = shift;
    my $err  = 0;
    my $f    = $self->get_filename;
    if ( !$f ) {
      $err = 1;
    }
    my $path = $self->get_configuration->get_path( -csv_files => 'Y' );
    my $season = $self->get_configuration->get_season;
    if ( $err == 0 && ($path) ) {
      return $path . "/$season/" . $f;
    }
  }

=head2 return_to_link

Returns the HTML code for the return link. The HTML is enclosed within a paragraph tag.
The identifier tells it which value to read from the configuration file.

print $o->return_to_link( "identifier" );

=cut

  #***************************************
  sub return_to_link {

    #***************************************
    my $self       = shift;
    my $identifier = shift;              # eg -results_index
    my $q          = $self->get_query;
    my $line;
    my ( $l, $t ) = $self->get_configuration->get_return_page( $identifier => "Y" );

    $l = "$l";
    if ( $l && $t ) {
      $line = $q->a( { -href => $l }, $t );
      $line = $q->p($line);
    }
    else {
      $self->logger->debug("No return information for $identifier page (href and title). $l $t");
    }
    return $line;
  }

=head2 _trim

Internal method which removes leading and trailing whitespace from the string passed
as an argument.

$s = $self->_trim( $s );

=cut

  #***************************************
  sub _trim {

    #***************************************
    my $self = shift;
    my $l    = shift;
    $l =~ s/$RE{ws}{crop}//g;

    #$l =~ s/^\s*([^\s])/$1/;
    #$l =~ s/([^\s])\s*$/$1/;
    return $l;
  }

  #=head2 logger
  #
  #This over-writes the one in Fcwrapper. Why?
  #
  #=cut
  #
  #  sub logger {
  #    my $self = shift;
  #    if ( !$self->{logger} ) {
  #      my $now  = DateTime->now();
  #      my $dir  = $self->get_configuration->get_path( -log_dir => 'Y' );
  #      my $file = undef;
  #      if ($dir) {
  #        $file = sprintf( "%s/%s%02d.log", $dir, "rs", $now->day );
  #      }
  #      print STDERR "file=$file\n";
  #      $self->{logger} = Logger::get_logger( "rs", $file );
  #    }
  #    return $self->{logger};
  #  }

  1;

}
