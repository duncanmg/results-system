
=head1 NAME

ResultsSystem::View::ResultsIndex

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

This renders the HTML for the results index.

There is a heading for each division and a table which contains links to the
results pages.

The labels for the links are dates of the form DD-Mon.

The links are only shown if the results page exists.

Thus at the beginning of the season, each table will contain a single
cell with the label "No results yet".

After one week, each table will contain one cell with a label such as '1-May'.

The table will gradually grow and each row can have up to 6 columns. The number of
rows is not limited.

=cut

=head1 INHERITS FROM

None

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::View::ResultsIndex;

use strict;
use warnings;
use Params::Validate qw/:all/;
use Data::Dumper;
use List::Util qw/min/;

use ResultsSystem::View;
use parent qw/ResultsSystem::View/;

my $NUM_COLS = 6;

=head2 new

Constructor for the ResultIndex object. Inherits from Parent.

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->set_arguments( [qw/ logger configuration/], $args );

  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF } );
  $self->logger->debug( Dumper $args);

  my $c = $self->get_configuration;

  my $all_divisions_html = "";
  foreach my $div ( @{ $args->{-data} } ) {
    my $div_html = $self->process_division($div);
    $all_divisions_html .= $div_html;
  }

  my ( $l, $t ) = $c->get_return_page( -results_index => 1 );

  $all_divisions_html = $self->merge_content(
    $self->get_heading_html,
    { TITLE           => $c->get_descriptors( -title  => "Y" ),
      SEASON          => $c->get_descriptors( -season => "Y" ),
      CONTENT         => $all_divisions_html,
      RETURN_TO_LINK  => $l,
      RETURN_TO_TITLE => $t,
      NUM_COLS        => $NUM_COLS,
    }
  );

  $self->render(
    { -data => $self->merge_default_stylesheet(
        $self->merge_content(
          $self->html_wrapper, { CONTENT => $all_divisions_html, PAGETITLE => 'Results System' }
        )
      )
    }
  );
  return 1;
}

=head2 process_division

=cut

sub process_division {
  my ( $self, $div ) = validate_pos( @_, 1, { type => HASHREF } );

  my $dates = $div->{dates};

  my $max_width = min( scalar(@$dates), $NUM_COLS );
  $max_width = 1 if !$max_width;

  my $blocks =
    scalar(@$dates)
    ? $self->blocks( $dates, $max_width, { matchdate => '&nbsp;', url => "" } )
    : $self->blocks( [ { matchdate => 'No results yet', url => "" } ],
    $max_width, { matchdate => '&nbsp;', url => "" } );

  my $html = "";
  foreach my $block (@$blocks) {
    my $cells = $self->merge_array( $self->get_division_table_cell_html, $block );
    $html .= $self->merge_content( $self->get_division_table_row_html, { cells => $cells } );
    $self->logger->debug( Dumper $html);
  }
  my $division_html = $self->merge_content( $self->get_division_table_html,
    { division_table_rows => $html, name => $div->{menu_name} } );

  return $division_html;
}

=head2 blocks

Split the list into blocks of length $len. If necessary,
pad the last blocks with $filler.

=cut

sub blocks {
  my ( $self, $list, $len, $filler ) = @_;
  my $bits   = [];
  my $i      = 0;
  my $bit_no = 0;
  foreach my $l (@$list) {
    if ( $i < $len ) {
      push( @$bits, [] ) if !$bits->[$bit_no];
      push @{ $bits->[$bit_no] }, $l;
      $i++;
    }
    else {
      $i = 0;
      $bit_no++;
    }
  }

  while ( $i < $len ) {
    last if $i == 0;
    push @{ $bits->[$bit_no] }, $filler;
    $i++;
  }
  return $bits;
}

=head2 get_heading_html

=cut

sub get_heading_html {
  return <<'HTML';
        <h1>[% TITLE %] - [% SEASON %]</h1>
        <h1>Index of the Results by Match Date and Division</h1>
        <p><a href="[% RETURN_TO_LINK %]"/>[% RETURN_TO_TITLE %]</a></p>
	<!-- The dates for each division are in a table with a maximum of [% NUM_COLS %] columns -->
        <!-- Each cell will contain a link with a label of the form DD-Mon. -->
	[% CONTENT %]
HTML
}

=head2 get_division_table_html

=cut

# *********************************************************
sub get_division_table_html {

  # *********************************************************
  my $self = shift;

  return <<'HTML';

    <h2>[% name %]</h2>

    <table>
      [% division_table_rows %]
    </table>
HTML

}

=head2 get_division_table_cell_html

=cut

sub get_division_table_cell_html {
  my $self = shift;
  return <<'HTML';

<td><a href="[% url %]">[% matchdate %]</td>
HTML

}

=head2 get_division_table_row_html

=cut

sub get_division_table_row_html {
  my $self = shift;
  return <<'HTML';
   <tr>[% cells %]</tr>
HTML
}

=head1 INTERNAL (PRIVATE) METHODS

=cut

1;

