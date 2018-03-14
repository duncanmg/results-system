
=head1 NAME

ResultsSystem::View::Week::Results

=cut

=head1 SYNOPSIS

=cut

=head1 DESCRIPTION

=cut

=head1 INHERITS FROM

ResultsSystem::View

=cut

=head1 EXTERNAL (PUBLIC) METHODS

=cut

{

  package ResultsSystem::View::Week::Results;

  use strict;
  use warnings;
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

    foreach my $r ( @{ $d->{rows} } ) {
      $r->{team}        = $self->encode_entities( $r->{team} );
      $r->{performanes} = $self->encode_entities( $r->{performances} );
    }

    my $table_rows = $self->create_table_rows( $d->{rows} );

    my $c = $self->get_configuration;

    my $html = $self->merge_content(
      $self->get_html,
      { ROWS      => $table_rows,
        SYSTEM    => $d->{SYSTEM},
        SEASON    => $c->get_descriptors( -season => "Y" ),
        WEEK      => $d->{week},
        MENU_NAME => $d->{MENU_NAME},
        TITLE     => $c->get_descriptors( -title => "Y" ),
        TIMESTAMP => localtime() . "",
      }
    );

    $html = $self->merge_content( $self->html_wrapper,
      { CONTENT => $html, PAGETITLE => 'Results System' } );

    $html = $self->merge_default_stylesheet($html);

    $self->set_division( $d->{division} )->set_week( $d->{week} );
    $self->write_file($html);

    return 1;
  }

=head2 create_table_rows

=cut

  sub create_table_rows {
    my ( $self, $rows ) = @_;

    my $table = "";
    my $i     = 0;
    for ( my $r = 0; $r < 10; $r++ ) {

      last if !$rows->[$i];

      $table .= $self->merge_content( $self->get_row_html, $rows->[$i] );
      $i++;
      $table .= $self->merge_content( $self->get_row_html, $rows->[$i] );
      $i++;
      $table .= $self->_blank_line;

    }

    return $table;
  }

=head2 get_html

=cut

  #***************************************
  sub get_html {

    #***************************************
    my $self = shift;

    my $html = q~
      <script type="text/javascript" src="menu_js.pl?system=[% SYSTEM %]&page=week_fixtures"></script>
      <h1>[% TITLE %] [% SEASON %]</h1>
      <h1>Results For Division [% MENU_NAME %] Week [% WEEK %]</h1>
      <p><a href="results_system.pl?system=[% SYSTEM %]&page=results_index">Return To Results Index</a></p>

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

      <p class="timestamp">[% TIMESTAMP %]</p>
~;

    return $html;

  }

=head2 get_row_html

=cut

  sub get_row_html {

    return q!
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
!;
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

    return q!
    <tr>
    <td class="teamcol">&nbsp;</td><td colspan="10">&nbsp;</td>
    </tr>
!;
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
    my ( $f, $FP );

    $f = $self->build_full_filename;

    open( $FP, ">", $f )
      || die ResultsSystem::Exception->new( "WRITE_ERR",
      "Unable to open file $f for writing. " . $! );

    print $FP $line;
    close $FP;
    return 1;
  }

=head2 build_full_filename

=cut

  sub build_full_filename {
    my ( $self, $data ) = @_;

    my $c = $self->get_configuration;
    my $dir = $c->get_path( -results_dir_full => "Y" );
    die ResultsSystem::Exception->new( 'DIR_DOES_NOT_EXIST',
      "Result directory $dir does not exist." )
      if !-d $dir;

    my $f = $self->get_division;    # The csv file
    my $w = $self->get_week;        # The csv file
    $f =~ s/\..*$//;                # Remove extension
    $f = "$dir/${f}_$w.htm";        # Add the path

    return $f;
  }

=head2 get_division

=cut

  sub get_division {
    my $self = shift;
    return $self->{division};
  }

=head2 set_division

=cut

  sub set_division {
    my ( $self, $v ) = @_;
    $self->{division} = $v;
    return $self;
  }

=head2 get_week

=cut

  sub get_week {
    my $self = shift;
    return $self->{week};
  }

=head2 set_week

=cut

  sub set_week {
    my ( $self, $v ) = @_;
    $self->{week} = $v;
    return $self;
  }

  1;

}
