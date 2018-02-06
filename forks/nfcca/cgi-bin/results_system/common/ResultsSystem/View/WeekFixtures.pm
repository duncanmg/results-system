# ******************************************************
#
# Name: WeekFixtures.pm
#
# 0.1  - 27 Jun 08 - POD added.
#
# ******************************************************

=head1 WeekFixtures.pm

=cut

{

  package ResultsSystem::View::WeekFixtures;

  use strict;
  use warnings;

  use Data::Dumper;

  use parent qw/ResultsSystem::View/;

=head1 Public Methods

=cut

=head2 new

Constructor for the WeekFixtures object. Inherits from Parent.

=cut

  #***************************************
  sub new {

    #***************************************
    my ($class, $args)=@_;
    my $self = {};
    bless $self, $class;

    $self->set_logger($args->{-logger}) if $args->{-logger};
    $self->set_configuration($args->{-configuration}) if $args->{-configuration};

    return $self;
  }

=head2 run

=cut

  sub run {
    my ($self, $data)=@_;

    my $table_rows = $self->create_table_rows($data->{rows});

    my $html = $self->merge_content( $self->get_html, { rows => $table_rows } );

    $self->render({ -data => $html});

    return 1;
  }

=head2 create_table_rows

=cut

sub create_table_rows {
  my ($self,$rows)=@_;

  my $table = "";
  my $i=0;
  for (my $r=0; $r<10; $r++) {

    last if ! $rows->[$i];

    $table .= $self->merge_content($self->get_row_html, $rows->[$i]);
    $i++;
    $table .= $self->merge_content($self->get_row_html, $rows->[$i]);
    $i++;
    $table .= $self->blank_line;

  }

  return $table;
}

  #***************************************
  sub get_html {

    #***************************************
    my $self = shift;

    my $html = q!
      <script type="text/javascript" src="menu_js.pl?system=[% SYSTEM %]&page=week_fixtures"></script>
      <h1>[% TITLE %] [% SEASON %]</h1>
      <h1>Fixtures For Division [% MENU_NAME %] Week [% WEEK %]<h1>
      <h1>Results For Division [% MENU_NAME %] Week [% WEEK %]<h1>
      <p><a href="results_system.pl?system=[% SYSTEM %]&page=results_index">Return To Results Index</a></p>

      <form id="menu_form" name="menu_form" method="post" action="results_system.pl"
      onsubmit="return validate_menu_form();"
      target = "f_detail">

      <table class='week_fixtures'>
      <tr>
      <th class="teamcol">Team</th>
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
      <input type="hidden" id="matchdate" name="matchdate" value="[% MATCHDATE %]"/>
      <input type="hidden" id="page" name="page" value="save_results"/>
      <input type="hidden" id="system" name="system" value="[% SYSTEM %]"/>

      <input type="submit" value="Save Changes"/>
      </form>
!;

    return $html;

  }

=head2 get_row_html

=cut

sub get_row_html {

return q!
!;
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

=head2 _fixture_line

Returns an HTML string containing a table row.

=cut

  #***************************************
  sub _fixture_line {

    #***************************************
    my $self = shift;

    return q!
    <tr>
    <td> <input type="text" name="[% TEAM %]" id="[%TEAM %] size="32" readonly="readonly"/> </td>
    <td> <select name="[% PLAYED %]" size="2" selected="[% SELECTED_PLAYED %]" onchange="calculate_points( this, [% ROW_NUMBER %] )">
      <option value="Y">Y</option>
      <option value="N">N</option>
      <option value="A">A</option>
      </select>
    </td>
    <td> <select name="[% RESULT %]" size="2" selected="[% SELECTED_RESULT %]" onchange="calculate_points( this, [% ROW_NUMBER %] )">
      <option value="W">W</option>
      <option value="L">L</option>
      <option value="T">T</option>
      </select>
    </td>
    <td> <input name="[% RUNS %]" id="[$ RUNS %]" type="number" min="0"/></td>
    <td> <input name="[% WICKETS %]" id="[% WICKETS %]" type="number" min="0"/></td>
    <td> <input type="text"  name="[% PERFORMANCES %]" id="[% PERFORMANCES %]"/></td>
    <td> <input  name="[% RESULTPTS %]" id="[% RESULTPTS %]" type="number" min="0" onchange="calculate_points( this, [% ROW_NUMBER %] )"/></td>
    <td> <input name="[% BATTINGPTS %]" id="[% BATTINGPTS %]" type="number" min="0" onchange="calculate_points( this, [% ROW_NUMBER %] )"/></td>
    <td> <input name="[% BOWLINGPTS %]" id="[% BOWLINGPTS %]" type="number" min="0" onchange="calculate_points( this, [% ROW_NUMBER %] )"/></td>
    <td> <input name="[% PENALTYPTS %]" id="[% PENALTYPTS %]" type="number" min="0" onchange="calculate_points( this, [% ROW_NUMBER %] )"/></td>
    <td> <input name="[% TOTALPTS %]" id="[% TOTALPTS %]" type="number" onchange="calculate_points( this, [% ROW_NUMBER %] )"/></td>
    </tr>
!;

  }

  1;

}
