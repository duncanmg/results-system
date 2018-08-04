
=head1 NAME

ResultsSystem::Model::Store::Divisions

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM



=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::Model::Store::Divisions;

use strict;
use warnings;
use Carp;

use XML::Simple;
use Sort::Maker;
use List::MoreUtils qw/ first_value any /;
use Regexp::Common qw /whitespace/;
use Data::Dumper;
use Params::Validate qw/:all/;

use ResultsSystem::Exception;

=head2 Model::Store::Divisions Setup

=cut

=head3 new

Constructor for the ResultsSystem::Model::Store::Divisions object. Optionally accepts the full filename
of the configuration file as an argument. Does not read the file at this point.

If -full_filename is not provided, then it must be set explicitly before the file 
can be read.

  $c = ResultsSystem::Model::Store::Divisions->new( -full_filename => "/a/b/divisions.xml",
    -logger => $logger );

or 

  $c = ResultsSystem::Model::Store::Divisions->new(-logger => $logger);
  $c->set_full_filename("/a/b/divisions.xml");

Requires -logger

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;
  my $err = 0;

  $self->set_logger( $args->{-logger} );

  $err = $self->set_full_filename( $args->{-full_filename} ) if $args->{-full_filename};

  return $self;
}

=head3 set_full_filename

Sets the full filename of the configuration file. Filters out
characters other than alphanumeric characters, "_", ".", or "/".

=cut

#***************************************
sub set_full_filename {

  #***************************************
  my $self = shift;
  $self->{FULL_FILENAME} = shift;
  return $self;
}

=head3 read_file

Read the divisions file. Returns an error if the file doesn't exist or the read fails.

$err = $c->read_file();

Uses the full filename given by $self->_get_full_filename().

=cut

#***************************************
sub read_file {

  #***************************************
  my $self = shift;
  my $err  = 0;

  $err = $self->_read_file();
  return $err if $err;

  return $err;
}

=head3 set_logger

=cut

sub set_logger {
  my ( $self, $logger ) = @_;
  $self->{LOGGER} = $logger;
  return $self;
}

=head2 Menu Handling

=cut

=head3 get_menu_names

Returns a list of hash references sorted by menu_position. Each hash reference has 3 elements: menu_position, menu_name and csv_file.

 @x = $c->get_menu_names();
 print $x[2]->{menu_position} . "\n";

=cut

#***************************************
sub get_menu_names {

  #***************************************
  my $self = shift;
  my $tags = $self->_get_tags();
  my @sorted_list;
  my $div_array_ref = $tags->{divisions}[0]{division};
  if ( !$div_array_ref ) {
    return;
  }
  my @div_array = @$div_array_ref;

  # print $div_array[1]{menu_position}[0] . "\n";

  foreach my $d (@div_array) {
    my %h = (
      menu_position => $d->{menu_position}[0],
      menu_name     => $d->{menu_name}[0],
      csv_file      => $d->{csv_file}[0]
    );
    $h{menu_position} = $self->_trim( $h{menu_position} );
    $h{menu_name}     = $self->_trim( $h{menu_name} );
    $h{csv_file}      = $self->_trim( $h{csv_file} );
    push @sorted_list, \%h;
  }

  my $sorter = make_sorter(
    qw( ST ),
    number => {
      code       => '$_->{menu_position}',
      descending => 0
    }
  );
  @sorted_list = $sorter->(@sorted_list);
  return @sorted_list;

}

=head3 get_name

This method returns the hash reference for the csv_file or menu_name passed as an argument.

 $h_ref = $c->get_name( -menu_name => "County 1" );
 print $h_ref->{csv_file} . "\n";
 
 $h_ref = $c->get_name( -cev_file => "CD1.csv" );
 print $h_ref->{menu_name} . "\n";

=cut

#***************************************
sub get_name {

  #***************************************
  my $self = shift;
  my %args = (@_);
  my $t;

  my @list = $self->get_menu_names;
  if ( $args{-menu_name} ) {
    $t = first_value { $_->{menu_name} eq $args{-menu_name} } @list;
  }
  else {
    $t = first_value { $_->{csv_file} eq $args{-csv_file} } @list;
  }
  return $t;    # Hash ref
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 logger

=cut

sub logger {
  my $self = shift;
  return $self->{LOGGER};
}

=head2 _trim

Remove the leading and trailing whitespace from a string passed as as argument.

$s = $c->_trim( $s );

=cut

#***************************************
sub _trim {

  #***************************************
  my $self = shift;
  my $s    = shift;
  return $s if !defined $s;
  $s =~ s/$RE{ws}{crop}//xg;

  #$s =~ s/^\s*([^\s])/$1/;
  #$s =~ s/([^\s])\s*$/$1/;
  return $s;
}

=head2 _get_tags

Internal method which gets the full data structure as read
from the configuration file.

=cut

#***************************************
sub _get_tags {

  #***************************************
  my $self = shift;
  croak( ResultsSystem::Exception->new( 'NO_TAGS_DEFINED', 'No tags defined' ) )
    if !$self->{TAGS};
  return $self->{TAGS};
}

=head2 _read_file

Does the hard work for read_file().

=cut

#***************************************
sub _read_file {

  #***************************************
  my $self = shift;
  my $err  = 0;
  my $main_xml;

  croak( ResultsSystem::Exception->new( 'FILENAME_NOT_SET', 'full_filename is not set' ) )
    if !$self->_get_full_filename;

  croak( ResultsSystem::Exception->new( 'FILE_DOES_NOT_EXIST', $self->_get_full_filename ) )
    if !-f $self->_get_full_filename;

  ( $err, $main_xml ) = $self->_load_file( $self->_get_full_filename );
  return $err if $err;

  $self->{TAGS} = $main_xml;

  return $err;
}

=head2 _load_file

Read the xml file. Returns an error if the file doesn't exist or the read fails.

($err, $xml) = $c->_load_file($full_filename);

=cut

#***************************************
sub _load_file {

  #***************************************
  my ( $self, $full_filename ) = @_;
  my $err = 0;
  my ($tags);

  my $xml = XML::Simple->new();
  return 1 if !$xml;

  eval {
    $tags = $xml->XMLin(
      $full_filename,
      NoAttr        => 1,
      ForceArray    => 1,
      SuppressEmpty => ""
    );
    1;
  } || do {
    $self->logger->error($@);
    croak( ResultsSystem::Exception->new( 'XML_ERROR', "Error reading XML $@" ) );
  };

  $self->logger(1)->debug("File read");

  return ( 0, $tags );
}

=head2 _get_full_filename

Returns the full filename of the divisions xml file.

=cut

#***************************************
sub _get_full_filename {

  #***************************************
  my $self = shift;
  return $self->{FULL_FILENAME};
}

1;

__END__

=head1 Example Model::Store::Divisions File

The divisions file is an XML file.

 <xml>

=head2 divisions

 <divisions>

  <division>
  
    <menu_position>
      1
    </menu_position>
    <menu_name>
      U9
    </menu_name>
    <csv_file>
      U92008.csv
    </csv_file>
    
  </division>
  
  <division>
  
    <menu_position>
      2
    </menu_position>
    <menu_name>
      U11A
    </menu_name>  
    <csv_file>
      U11A2008.csv
    </csv_file>
    
  </division>
  
  <division>
  
    <menu_position>
      3
    </menu_position>
    <menu_name>
      U11B East
    </menu_name>  
    <csv_file>
      U11BEast2008.csv
    </csv_file>
    
  </division>
  
  <division>
  
    <menu_position>
      4
    </menu_position>
    <menu_name>
      U11B West
    </menu_name>
    <csv_file>
      U11BWest2008.csv
    </csv_file>
  
  </division>
  
  <division>
  
    <menu_position>
      5
    </menu_position>
    <menu_name>
      U13A
    </menu_name>
    <csv_file>
      U13A2008.csv
    </csv_file>
  
  </division>
  
  <division>
  
    <menu_position>
      6
    </menu_position>
    <menu_name>
      U13B East
    </menu_name>
    <csv_file>
      U11BEast2008.csv
    </csv_file>
  
  </division>
  
  <division>
  
    <menu_position>
      7
    </menu_position>
    <menu_name>
      U13B West
    </menu_name>
    <csv_file>
      U13BWest2008.csv
    </csv_file>
  
  </division>
  
  <division>
  
    <menu_position>
      8
    </menu_position>
    <menu_name>
      U15A
    </menu_name>
    <csv_file>
      U15A2008.csv
    </csv_file>
  
  </division>

  <division>
  
    <menu_position>
      9
    </menu_position>
    <menu_name>
      U15B East
    </menu_name>
    <csv_file>
      U15BEast2008.csv
    </csv_file>
  
  </division>

  <division>
  
    <menu_position>
      10
    </menu_position>
    <menu_name>
      U15B West
    </menu_name>
    <csv_file>
      U15BWest2008.csv
    </csv_file>
  
  </division>

  <division>
  
    <menu_position>
      11
    </menu_position>
    <menu_name>
      U15B Central
    </menu_name>
    <csv_file>
      U15BCentral2008.csv
    </csv_file>
  
  </division>

 </divisions>

 </xml>

=cut
