package ResultsSystem::IO::XML;
use strict;
use warnings;

use Moo;
use File::Copy qw/ copy/;
use File::Basename;
use Path::Class;
use XML::Simple qw/:strict/;
use Params::Validate qw/:all/;

has 'backup_dir' => ( 'is' => 'ro', 'default' => sub {"."} );
has 'backup_ext' => ( 'is' => 'ro', 'default' => sub { time() . "" } );
has 'write_dir'  => ( 'is' => 'ro', 'default' => sub {"."} );
has 'full_filename' => ( 'is' => 'ro', 'required' => 1 );

sub _backup {
  my $self = shift;
  my ( $name, $path, $suffix ) = fileparse( $self->full_filename );
  copy(
    $self->full_filename,
    Path::Class::File->new(
      $self->backup_dir, join( '.', ( $name, $suffix, $self->backup_ext ) )
    )
  ) || die $!;
  return 1;
}

sub _write {
  my ( $self, $input ) = validate_pos( @_, 1, 1 );
  my $FP;
  my $xml = XML::Simple->new();
  my $out = $xml->XMLout( $input, KeepRoot => 1, KeyAttr => [] );
  open( $FP, '>', $self->full_filename ) || die $!;
  print $FP $out || die $!;
  close $FP || die $!;
  return 1;
}

sub _read {
  my ($self) = validate_pos( @_, 1 );
  my $FP;
  open( $FP, $self->full_filename ) || die $!;
  my @lines = readline($FP) || die $!;
  my $xml   = XML::Simple->new();
  my $in    = $xml->XMLin( join( "\n", @lines ) );
  return $in;
}

1;
