package ResultsSystem::IO::XML;
use strict;
use warnings;

use Moo;
use File::Copy qw/ copy/;
use File::Basename;
use Path::Class;
use XML::Simple qw/:strict/;
use Params::Validate qw/:all/;

=head1 Description

Read or write to the XML file which contains the results for a division
and a week.

See "Example Perl" and "Example XML".

=cut

=head1 Attributes

=over

=item backup_dir

Directory for backups. Defaults to the current directory.

=item backup_ext

The extension given to the backups. Defaults to a timestamp
which does not update.

abc.xml --> abc.xml.12345678

=item write_dir

The directory to write the files to. Defaults to the current directory.

=item full_filename

The full path and filename of the XML file to be read.

=back

=cut

has 'backup_dir' => ( 'is' => 'ro', 'default' => sub {"."} );
has 'backup_ext' => ( 'is' => 'ro', 'default' => sub { time() . "" } );
has 'write_dir'  => ( 'is' => 'ro', 'default' => sub {"."} );
has 'full_filename' => ( 'is' => 'ro' );

=head1 External Methods

=cut

=head2 new

my $obj = ResultsSystem::IO::XML->new()

Return a new object. All the constructor attributes are optional. However,
full_filename does not have a default, so you must set it before you can
read or write.

=cut

=head2 read

Return the current contents of the XML file given in $self->full_filename as a hash 
ref in the form shown in "Example Perl".

my $result_set = $self->read();

=cut

sub read {
  my ($self) = validate_pos( @_, 1 );
  return $self->_read();
}

=head2 write

Accept a result_set hash ref containing one or more week worth or results.
Backs up the file before changing it.

$self->write($input);

=cut

sub write {
  my ( $self, $input ) = validate_pos( @_, 1, { type => HASHREF } );
  $self->_backup();
  $self->_write();
  return 1;
}

=head1 Internal Methods

=cut

=head2 _backup

$self->_backup()

Makes a copy of the file in $self->full_filename and puts it in the
directory given in $self->backup_dir with a timestamp and the extension
given in $self->backup_ext.

Dies on error.

=cut

sub _backup {
  my $self = shift;
  my ( $name, $path, $suffix ) = fileparse( $self->full_filename );
  die "full_filename is not defined" if !$self->full_filename;
  copy(
    $self->full_filename,
    Path::Class::File->new(
      $self->backup_dir, join( '.', ( $name, $suffix, $self->backup_ext ) )
    )
  ) || die $!;
  return 1;
}

=head2 _read

$self->_read()

Reads the contents of the file given in $self->full_filename and returns it as a hash ref.
See "Example Perl".

=cut

sub _read {
  my ($self) = validate_pos( @_, 1 );
  my $FP;
  die "full_filename is not defined" if !$self->full_filename;
  open( $FP, $self->full_filename ) || die $!;
  my @lines = ();
  while (<$FP>) {
    push @lines, $_;
  }
  my $xml = XML::Simple->new();
  my $in = $xml->XMLin( join( "\n", @lines ), ForceArray => 1, KeyAttr => [], KeepRoot => 1 );
  return $in;
}

=head2 _write

Accept a hash ref in the format given in "Example Perl". Writes it to the
file given in $self->full_filename as XML in the format given in
"Example XML".

=cut

sub _write {
  my ( $self, $input ) = validate_pos( @_, 1, 1 );
  my $FP;
  my $xml = XML::Simple->new();
  my $out = $xml->XMLout(
    $input,
    KeepRoot => 1,
    KeyAttr  => [],
    RootName => "Result"
  );
  die "full_filename is not defined" if !$self->full_filename;
  open( $FP, '>', $self->full_filename ) || die $!;
  print $FP $out || die $!;
  close $FP || die $!;
  return 1;
}

=head1 Example Perl

  my $VAR1 = {
    'match' => [
      { 'match_date'   => [ '21-Jan-2014' ],
        'played'       => [ 'Y' ],
        'away'         => [ 'Waterlooville' ],
        'away_details' => [
          { 'runs_scored'    => [ '100' ],
            'wickets_lost'   => [ '5' ],
            'bowling_points' => [ '3' ],
            'penalty_points' => [ '0' ],
            'batting_points' => [ '5' ],
            'result'         => [ 'W' ]
          }
        ],
        'home_details' => [
          { 'runs_scored'    => [ '100' ],
            'wickets_lost'   => [ '5' ],
            'bowling_points' => [ '3' ],
            'penalty_points' => [ '0' ],
            'batting_points' => [ '5' ],
            'result'         => [ 'W' ]
          }
        ],
        'home' => [ 'Purbrook' ]
      },
      { 'match_date'   => [ '21-Jan-2014' ],
        'played'       => [ 'Y' ],
        'away'         => [ 'P\'mouth & S\'sea' ],
        'away_details' => [
          { 'runs_scored'    => [ '100' ],
            'wickets_lost'   => [ '5' ],
            'bowling_points' => [ '3' ],
            'penalty_points' => [ '0' ],
            'batting_points' => [ '5' ],
            'result'         => [ 'W' ]
          }
        ],
        'home_details' => [
          { 'runs_scored'    => [ '100' ],
            'wickets_lost'   => [ '5' ],
            'bowling_points' => [ '3' ],
            'penalty_points' => [ '0' ],
            'batting_points' => [ '5' ],
            'result'         => [ 'W' ]
          }
        ],
        'home' => [ 'Fareham & Crofton' ]
      }
    ]
  };

=cut

=head1 Example XML

  <result_set>
  <match>
          <home>Purbrook</home>
          <away>Waterlooville</away>
          <match_date>21-Jan-2014</match_date>
          <played>Y</played>
          <home_details>
                  <runs_scored>100</runs_scored>
                  <wickets_lost>5</wickets_lost>
                  <batting_points>5</batting_points>
                  <bowling_points>3</bowling_points>
                  <penalty_points>0</penalty_points>
                  <result>W</result>
          </home_details>
          <away_details>
                  <runs_scored>100</runs_scored>
                  <wickets_lost>5</wickets_lost>
                  <batting_points>5</batting_points>
                  <bowling_points>3</bowling_points>
                  <penalty_points>0</penalty_points>
                  <result>W</result>
          </away_details>
  </match>
  <match>
          <home>Fareham &amp; Crofton</home>
          <away>P'mouth &amp; S'sea</away>
          <match_date>21-Jan-2014</match_date>
          <played>Y</played>
          <home_details>
                  <runs_scored>100</runs_scored>
                  <wickets_lost>5</wickets_lost>
                  <batting_points>5</batting_points>
                  <bowling_points>3</bowling_points>
                  <penalty_points>0</penalty_points>
                  <result>W</result>
          </home_details>
          <away_details>
                  <runs_scored>100</runs_scored>
                  <wickets_lost>5</wickets_lost>
                  <batting_points>5</batting_points>
                  <bowling_points>3</bowling_points>
                  <penalty_points>0</penalty_points>
                  <result>W</result>
          </away_details>
  </match>
  </result_set>

=cut

1;
