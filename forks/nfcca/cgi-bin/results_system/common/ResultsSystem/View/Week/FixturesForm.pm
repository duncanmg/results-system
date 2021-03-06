
=head1 NAME

ResultsSystem::View::Week::FixturesForm

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

L<ResultsSystem::View::Week>

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

package ResultsSystem::View::Week::FixturesForm;

use strict;
use warnings;
use Params::Validate qw/:all/;

use Data::Dumper;
use ResultsSystem::View::Week;

use parent qw/ResultsSystem::View::Week/;

=head2 new

Constructor for the FixturesForm object. Inherits from Parent.

=cut

#***************************************
sub new {

  #***************************************
  my ( $class, $args ) = @_;
  my $self = {};
  bless $self, $class;

  $self->set_logger( $args->{-logger} )               if $args->{-logger};
  $self->set_configuration( $args->{-configuration} ) if $args->{-configuration};
  $self->set_pwd_view( $args->{-pwd_view} )           if $args->{-pwd_view};

  return $self;
}

=head2 run

=cut

sub run {
  my ( $self, $data ) = @_;

  my $d = $data->{-data};
  $self->logger->debug( Dumper $data);
  my $table_rows = $self->create_table_rows( $d->{rows} );

  my $html = $self->merge_content( $self->get_html,
    { PASSWORD_TABLE => $self->get_pwd_view->get_pwd_fields } );

  $html = $self->merge_content(
    $html,
    { ROWS      => $table_rows,
      SYSTEM    => $d->{SYSTEM},
      SEASON    => $d->{SEASON},
      WEEK      => $d->{WEEK},
      MENU_NAME => $d->{MENU_NAME},
      TITLE     => $d->{TITLE},
      DIVISION  => $d->{DIVISION}
    }
  );

  $html = $self->merge_content( $self->html5_wrapper,
    { CONTENT => $html, PAGETITLE => 'Results System' } );

  $html = $self->merge_default_stylesheet($html);

  $self->render( { -data => $html } );

  return 1;
}

=head2 create_table_rows

=cut

sub create_table_rows {
  my ( $self, $rows ) = validate_pos( @_, 1, { type => ARRAYREF } );

  my $table   = "";
  my $i       = 0;
  my $matchno = 0;
  while ( $rows->[$i] ) {
    my $r = $rows->[$i];

    $r->{ha}        = 'home';
    $r->{matchno}   = $matchno;
    $r->{rownumber} = $i;
    my $merged_row = $self->merge_content( $self->get_row_html, $r );

    $merged_row = $self->merge_select_boxes( $merged_row, $r );

    $table .= $merged_row;
    $i++;
    $r              = $rows->[$i];
    $r->{ha}        = 'away';
    $r->{matchno}   = $matchno;
    $r->{rownumber} = $i;

    $merged_row = $self->merge_content( $self->get_row_html, $r );

    $merged_row = $self->merge_select_boxes( $merged_row, $r );

    $table .= $merged_row;
    $i++;

    $table .= $self->_blank_line;

    $matchno++;
  }

  return $table;
}

=head2 merge_select_boxes

=cut

sub merge_select_boxes {
  my ( $self, $row, $r ) = validate_pos( @_, 1, { type => SCALAR }, { type => HASHREF } );

  $row = $self->merge_if_else( $row, 'played_y', $r->{played}, 'Y', 'selected="selected"', '' );

  $row = $self->merge_if_else( $row, 'played_n', $r->{played}, 'N', 'selected="selected"', '' );

  $row = $self->merge_if_else( $row, 'played_a', $r->{played}, 'A', 'selected="selected"', '' );

  $row = $self->merge_if_else( $row, 'result_w', $r->{result}, 'W', 'selected="selected"', '' );

  $row = $self->merge_if_else( $row, 'result_l', $r->{result}, 'L', 'selected="selected"', '' );

  $row = $self->merge_if_else( $row, 'result_t', $r->{result}, 'T', 'selected="selected"', '' );

  return $row;
}

=head2 get_html

=cut

#***************************************
sub get_html {

  #***************************************
  my $self = shift;

  my $html = <<'HTML';
      <script src="/results_system/common/menu.js"></script>
      <h1>[% TITLE %] [% SEASON %]</h1>
      <h1>Fixtures For Division [% MENU_NAME %] Week [% WEEK %]</h1>
      <!-- <h1>Results For Division [% MENU_NAME %] Week [% WEEK %]<h1> -->
      <p><a href="results_system.pl?system=[% SYSTEM %]&page=results_index">Return To Results Index</a></p>

      <form id="menu_form" name="menu_form" method="post" action="results_system.pl"
      onsubmit="return validate_menu_form();"
      target = "f_detail">

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

      <input type="hidden" id="division" name="division" value="[% DIVISION %]"/>
      <input type="hidden" id="matchdate" name="matchdate" value="[% WEEK %]"/>
      <input type="hidden" id="page" name="page" value="save_results"/>
      <input type="hidden" id="system" name="system" value="[% SYSTEM %]"/>

      [% PASSWORD_TABLE %]
      <input type="submit" value="Save Changes"/>
      </form>
HTML

  return $html;

}

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 _blank_line

Returns a string containing HTML. The HTML is a table row
oith 11 cells. Each cell contains the &nbsp;

=cut

#***************************************
sub _blank_line {

  #***************************************
  my $self = shift;
  my %args = (@_);

  return <<'HTML';
    <tr>
    <td class="teamcol">&nbsp;</td><td colspan="10">&nbsp;</td>
    </tr>
HTML
}

=head2 get_row_html

Returns an HTML string containing a table row.

=cut

#***************************************
sub get_row_html {

  #***************************************
  my $self = shift;

  return <<'HTML';
    <tr>
    <td> <input type="text" id="[% ha %]team[% matchno %]" name="[% ha %]team[% matchno %]" value="[% team %]" readonly/> </td>
    <td> <select name="[% ha %]played[% matchno %]" size="1" onchange="calculate_points( this, [% matchno %] )">
      <option value="Y" [% played_y %]>Y </option>
      <option value="N" [% played_n %]>N </option>
      <option value="A" [% played_a %]>A </option>
      </select>
    </td>
    <td> <select name="[% ha %]result[% matchno %]" size="1" onchange="calculate_points( this, [% matchno %] )">
      <option value="W" [% result_w %]>W</option>
      <option value="L" [% result_l %]>L</option>
      <option value="T" [% result_t %]>T</option>
      </select>
    </td>
    <td> <input name="[% ha %]runs[% matchno %]" id="[% ha %]runs[% matchno %]" type="number" min="0" value="[% runs %]"/></td>
    <td> <input name="[% ha %]wickets[% matchno %]" id="[% ha %]wickets[% matchno %]" type="number" min="0" value="[% wickets %]"/></td>
    <td class="performances"> <input type="text"  name="[% ha %]performances[% matchno %]" id="[% ha %]performances[% matchno %]" value="[% performances %]"/></td>
    <td> <input  name="[% ha %]resultpts[% matchno %]" id="[% ha %]resultpts[% matchno %]" type="number" min="0" onchange="calculate_points( this, [% matchno %] )" value="[% resultpts %]"/></td>
    <td> <input name="[% ha %]battingpts[% matchno %]" id="[% ha %]battingpts[% matchno %]" type="number" min="0" onchange="calculate_points( this, [% matchno %] )" value="[% battingpts %]"/></td>
    <td> <input name="[% ha %]bowlingpts[% matchno %]" id="[% ha %]bowlingpts[% matchno %]" type="number" min="0" onchange="calculate_points( this, [% matchno %] )" value="[% bowlingpts %]"/></td>
    <td> <input name="[% ha %]penaltypts[% matchno %]" id="[% ha %]penaltypts[% matchno %]" type="number" min="0" onchange="calculate_points( this, [% matchno %] )" value="[% penaltypts %]"/></td>
    <td> <input name="[% ha %]totalpts[% matchno %]" id="[% ha %]totalpts[% matchno %]" type="number" onchange="calculate_points( this, [% matchno %] )" value="[% totalpts %]"/></td>
    </tr>
HTML

}

=head2 get_pwd_view

=cut

sub get_pwd_view {
  my $self = shift;
  return $self->{pwd_view};
}

=head2 set_pwd_view

=cut

sub set_pwd_view {
  my ( $self, $v ) = @_;
  $self->{pwd_view} = $v;
  return $self;
}

1;
