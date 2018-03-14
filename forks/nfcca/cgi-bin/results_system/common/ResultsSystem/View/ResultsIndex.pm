
=head1 NAME

ResultsSystem::View::ResultsIndex

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

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

use ResultsSystem::View;
use parent qw/ResultsSystem::View/;

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
      RETURN_TO_TITLE => $t
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

  my $max_width = 6;
  my $data      = $div->{dates};
  my $blocks    = $self->blocks( $data, $max_width, { matchdate => '&nbsp;', url => "" } );

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
  return q!
        <h1>[% TITLE %] - [% SEASON %]</h1>
        <p><a href="[% RETURN_TO_LINK %]"/>[% RETURN_TO_TITLE %]</a></p>
	[% CONTENT %]
!;
}

=head2 get_division_table_html

=cut

# *********************************************************
sub get_division_table_html {

  # *********************************************************
  my $self = shift;

  return q!

    <h2>[% name %]</h2>

    <table>
      [% division_table_rows %]
    </table>
    !;

}

=head2 get_division_table_cell_html

=cut

sub get_division_table_cell_html {
  my $self = shift;
  return q!
<td><a href="[% url %]">[% matchdate %]</td>
!;

}

=head2 get_division_table_row_html

=cut

sub get_division_table_row_html {
  my $self = shift;
  return q!
   <tr>[% cells %]</tr>
 !
}

#=head2 output_html
#
#This method returns HTML for all the divisions. The HTML starts with a single level one
#heading. This is followed by the HTML for each division. This consists of a level two
#heading and a table. This list of divisions is read from the configuration file.
#
#( $err, $line ) = output_html;
#
#=cut
#
#  # *********************************************************
#  sub output_html {
#
#    # *********************************************************
#    my $self = shift;
#    my $err  = 0;
#
#    my $q     = $self->get_query;
#    my $c     = $self->get_configuration;
#    my @names = $c->get_menu_names;
#    my ( $line, $l );
#    $self->logger->debug( scalar(@names) . " divisions to be listed." );
#
#    $line =
#        $line . "<h1>"
#      . $c->get_descriptors( -title => "Y" )
#      . " - Results "
#      . $c->get_descriptors( -season => "Y" )
#      . "</h1>\n";
#
#    $line = $line . $self->return_to_link("-results_index") . "\n";
#
#    my $d = $c->get_path( -csv_files => "Y" );
#    my $season = $c->get_season;
#    $d = "$d/$season";
#
#    foreach my $division (@names) {
#
#      eval {
#        ( $err, $l ) = $self->print_table( $d, $division->{csv_file}, $division->{menu_name} );
#        $line = $line . $l;
#      };
#      if ($@) {
#        $self->logger->error( "Problem processing " . $division->{menu_name} );
#        $self->logger->error( $@, 5 );
#        $err = 1;
#      }
#      if ( $err != 0 ) {
#        last;
#      }
#    }
#
#    return ( $err, $line );
#
#  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

1;

