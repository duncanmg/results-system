# ******************************************************
#
# Name: FixturesForm.pm
#
# 0.1  - 27 Jun 08 - POD added.
#
# ******************************************************

=head1 FixturesForm.pm

=cut

{

  package ResultsSystem::View::Week::FixturesForm;

  use strict;
  use warnings;
  use Params::Validate qw/:all/;

  use Data::Dumper;
  use ResultsSystem::View::Week;

  use parent qw/ResultsSystem::View::Week/;

=head1 Public Methods

=cut

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

    return $self;
  }

=head2 run

=cut

  sub run {
    my ( $self, $data ) = @_;

    my $d = $data->{-data};
    $self->logger->debug( Dumper $data);
    my $table_rows = $self->create_table_rows( $d->{rows} );

    my $html = $self->merge_content(
      $self->get_html,
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
    for ( my $r = 0; $r < 10; $r++ ) {
      my $r = $rows->[$i];
      last if !$r;

      $r->{ha}        = 'home';
      $r->{matchno}   = $matchno;
      $r->{rownumber} = $i;
      $table .= $self->merge_content( $self->get_row_html, $r );

      $i++;
      $r              = $rows->[$i];
      $r->{ha}        = 'away';
      $r->{matchno}   = $matchno;
      $r->{rownumber} = $i;
      $table .= $self->merge_content( $self->get_row_html, $r );
      $i++;
      $table .= $self->_blank_line;

      $matchno++;
    }

    return $table;
  }

  #***************************************
  sub get_html {

    #***************************************
    my $self = shift;

    my $html = q~
      <script src="menu_js.pl?system=[% SYSTEM %]&page=week_fixtures"></script>
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

      <input type="submit" value="Save Changes"/>
      </form>
~;

    return $html;

  }

=head1 Private Methods

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

    return q!
    <tr>
    <td class="teamcol">&nbsp;</td><td colspan="10">&nbsp;</td>
    </tr>
!;
  }

=head2 get_row_html

Returns an HTML string containing a table row.

=cut

  #***************************************
  sub get_row_html {

    #***************************************
    my $self = shift;

    return q!
    <tr>
    <td> <input type="text" id="[% ha %]team[% matchno %]" name="[% ha %]team[% matchno %]" value="[% team %]" readonly/> </td>
    <td> <select name="[% ha %]played[% matchno %]" size="2" onchange="calculate_points( this, [% rownumber %] )">
      <option value="Y">Y</option>
      <option value="N">N</option>
      <option value="A">A</option>
      </select>
    </td>
    <td> <select name="[% ha %]result[% matchno %]" size="2" onchange="calculate_points( this, [% rownumber %] )">
      <option value="W">W</option>
      <option value="L">L</option>
      <option value="T">T</option>
      </select>
    </td>
    <td> <input name="[% ha %]runs[% matchno %]" id="[% ha %]runs[% matchno %]" type="number" min="0" value="[% runs %]"/></td>
    <td> <input name="[% ha %]wickets[% matchno %]" id="[% ha %]wickets[% matchno %]" type="number" min="0" value="[% wickets %]"/></td>
    <td> <input type="text"  name="[% ha %]performances[% matchno %]" id="[% ha %]performances[% matchno %]" value="[% performances %]"/></td>
    <td> <input  name="[% ha %]resultpts[% matchno %]" id="[% ha %]resultpts[% matchno %]" type="number" min="0" onchange="calculate_points( this, [% rownumber %] )" value="[% resultpts %]"/></td>
    <td> <input name="[% ha %]battingpts[% matchno %]" id="[% ha %]battingpts[% matchno %]" type="number" min="0" onchange="calculate_points( this, [% rownumber %] )" value="[% battingpts %]"/></td>
    <td> <input name="[% ha %]bowlingpts[% matchno %]" id="[% ha %]bowlingpts[% matchno %]" type="number" min="0" onchange="calculate_points( this, [% rownumber %] )" value="[% bowlingpts %]"/></td>
    <td> <input name="[% ha %]penaltypts[% matchno %]" id="[% ha %]penaltypts[% matchno %]" type="number" min="0" onchange="calculate_points( this, [% rownumber %] )" value="[% penaltypts %]"/></td>
    <td> <input name="[% ha %]totalpts[% matchno %]" id="[% ha %]totalpts[% matchno %]" type="number" onchange="calculate_points( this, [% rownumber %] )" value="[% totalpts %]"/></td>
    </tr>
!;

  }
  1;

}
