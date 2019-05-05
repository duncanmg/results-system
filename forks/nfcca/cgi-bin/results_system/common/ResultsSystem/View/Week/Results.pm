
=head1 NAME

ResultsSystem::View::Week::Results

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

Writes the HTML file for the division. Get the full HTML filename from the configuration.

=cut

=head1 INHERITS FROM

ResultsSystem::View

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::View::Week::Results;

use strict;
use warnings;
use Carp;
use Params::Validate qw/:all/;

use Data::Dumper;

use parent qw/ResultsSystem::View/;

=head2 new

Constructor for the Week::Results object.

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->set_arguments( [qw/logger configuration results_html_full_filename/], $args );

  return $self;
}

=head2 run

$self->run( { -date => $data } );

Accepts the data for the week results and writes the HTML file.

$data is an array ref of hash refs.

The filename is read from the configuration.

=cut

sub run {
  my ( $self, $data ) = @_;

  my $d = $data->{-data};
  $self->logger->debug( Dumper $data);

  foreach my $r ( @{ $d->{rows} } ) {
    $r->{team}        = $self->encode_entities( $r->{team} );
    $r->{performanes} = $self->encode_entities( $r->{performances} );
  }

  my $table_rows = $self->_create_table_rows( $d->{rows} );

  my $c = $self->get_configuration;

  my $p =
      $c->get_path( "-cgi_dir" => "Y", -allow_not_exists => 1 )
    . "/common/results_system.pl?page=results_index&system="
    . $c->get_system;

  my $html = $self->merge_content(
    $self->_get_html,
    { ROWS               => $table_rows,
      SYSTEM             => $d->{SYSTEM},
      SEASON             => $c->get_descriptors( -season => "Y" ),
      WEEK               => $d->{week},
      MENU_NAME          => $d->{MENU_NAME},
      TITLE              => $c->get_descriptors( -title => "Y" ),
      TIMESTAMP          => localtime() . "",
      RESULTS_INDEX_HREF => $p,
    }
  );

  $html = $self->merge_content( $self->html5_wrapper,
    { CONTENT => $html, PAGETITLE => 'Results System' } );

  $html = $self->merge_default_stylesheet($html);

  $self->write_file($html);

  return 1;
}

=head2 get_results_html_full_filename

=cut

sub get_results_html_full_filename {
  my $self = shift;
  return $self->{results_html_full_filename};
}

=head2 set_results_html_full_filename

=cut

sub set_results_html_full_filename {
  my ( $self, $v ) = @_;
  $self->{results_html_full_filename} = $v;
  return $self;
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _blank_line

Returns a string containing HTML. The HTML is a table row
with 11 cells. Each cell contains the &nbsp;

=cut

#***************************************
sub _blank_line {

  #***************************************
  my $self = shift;
  my %args = (@_);
  my $line;

  return <<'HTML';
    <tr>
    <td class="teamcol">&nbsp;</td><td colspan="10">&nbsp;</td>
    </tr>
HTML
}

=head2 write_file

This method writes the string passed as an argument to an HTML file. The filename
is formed by replacing the .csv for the csv file with .htm. The file will be written
to the directory given by "table_dir" in the configuration file.

 $err = $lt->write_file( $line );

=cut

#***************************************
sub write_file {

  #***************************************
  my ( $self, $line ) = validate_pos( @_, 1, { type => SCALAR } );

  my $f = $self->get_results_html_full_filename;

  open( my $FP, ">", $f )
    || croak(
    ResultsSystem::Exception->new( "WRITE_ERR", "Unable to open file $f for writing. " . $! ) );

  print $FP $line;
  close $FP;
  return 1;
}

=head2 _create_table_rows

=cut

sub _create_table_rows {
  my ( $self, $rows ) = @_;

  my $table = "";
  my $i     = 0;
  while ( $rows->[$i] ) {

    $table .= $self->merge_content( $self->_get_row_html, $rows->[$i] );
    $i++;
    $table .= $self->merge_content( $self->_get_row_html, $rows->[$i] );
    $i++;
    $table .= $self->_blank_line;

  }

  return $table;
}

=head2 _get_html

=cut

#***************************************
sub _get_html {

  #***************************************
  my $self = shift;

  my $html = <<'HTML';
      <h1>[% TITLE %] [% SEASON %]</h1>
      <h1>Results For Division [% MENU_NAME %] Week [% WEEK %]</h1>
      <p><a href="[% RESULTS_INDEX_HREF %]">Return To Results Index</a></p>

      <table class='week_fixtures'>
      <tr>
      <th class="teamcol">Team</th>
      <th>Played</th>
      <th>Result</th>
      <th>Runs</th>
      <th>Wickets</th>
      <th class="performances">Performances</th>
      <th>Result Pts</th>
      <th>Batting Pts</th>
      <th>Bowling Pts</th>
      <th>Penalty Pts</th>
      <th>Total Pts</th>
      </tr>

      [% ROWS %]

      </table>

      <p class="timestamp">[% TIMESTAMP %]</p>
HTML

  return $html;

}

=head2 _get_row_html

=cut

sub _get_row_html {

  return <<'HTML';
<tr>
<td class="teamcol">[% team %]</td>
<td>[% played %]</td>
<td>[% result %]</td>
<td>[% runs %]</td>
<td>[% wickets %]</td>
<td>[% performances %]</td>
<td>[% resultpts %]</td>
<td>[% battingpts %]</td>
<td>[% bowlingpts %]</td>
<td>[% penaltypts %]</td>
<td>[% totalpts %]</td>
</tr>
HTML
}

1;

