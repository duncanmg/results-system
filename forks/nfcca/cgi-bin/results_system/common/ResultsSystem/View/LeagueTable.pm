  package ResultsSystem::View::LeagueTable;

  use strict;
  use warnings;
  use Carp;

  use Data::Dumper;
  use Params::Validate qw/:all/;

  use ResultsSystem::View;
  use parent qw/ ResultsSystem::View/;

=head1 NAME

ResultsSystem::View::LeagueTable

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

=head2 new

This is the constructor for a LeagueTable object. It inherits from ResultsSystem::View.

 my $l = LeagueTable->new( { -logger => $l, -configuration => $c } );
 $lt->run({-data => $data});

=cut

  #***************************************
  sub new {

    #***************************************
    my $class = shift;
    my $self  = {};
    bless $self, $class;
    my $args = shift;

    $self->set_logger( $args->{-logger} )               if $args->{-logger};
    $self->set_configuration( $args->{-configuration} ) if $args->{-configuration};
    $self->set_table_html_full_filename( $args->{-table_html_full_filename} )
      if $args->{-table_html_full_filename};

    return $self;
  }

=head2 run

  $lt->run({-data => $data});

=cut

  sub run {
    my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF } );

    my $html = $self->create_document($args);

    $self->write_file($html);
    return 1;
  }

=head2 create_document

=cut

  sub create_document {
    my ( $self, $args ) = validate_pos( @_, 1, { type => HASHREF } );

    my $c = $self->get_configuration;

    foreach my $r ( @{ $args->{-data}->{rows} } ) {
      $r->{team} = $self->encode_entities( $r->{team} );
    }

    my $html = $self->merge_array( $self->get_row_html, $args->{-data}->{rows} );

    $args->{-data}->{division} =~ s/\.csv//x;

    my $p =
        $c->get_path( "-cgi_dir" => "Y", -allow_not_exists => 1 )
      . "/common/results_system.pl?page=tables_index&system="
      . $c->get_system;

    $html = $self->merge_content(
      $self->get_html,
      { TABLE_ROWS        => $html,
        DESCRIPTOR        => $c->get_descriptors( -title => "Y" ),
        SEASON            => $c->get_descriptors( -season => "Y" ),
        TIMESTAMP         => $args->{-data}->{timestamp} || localtime() . "",
        DIVISION          => $args->{-data}->{division},
        TABLES_INDEX_HREF => $p,
      }
    );

    $html = $self->merge_content(
      $self->html5_wrapper,
      { CONTENT   => $html,
        PAGETITLE => 'Results System',
      }
    );

    $html = $self->merge_stylesheets( $html, ["/results_system/custom/nfcca/nfcca_styles.css"] );

    $self->logger->debug($html);

    return $html;
  }

  #=head2 _d
  #
  #This method sets an undefined value to 0. $v = $lt->_d( $v );
  #
  #=cut
  #
  #  #***************************************
  #  # Sets undefined values to 0.
  #  #***************************************
  #  sub _d {
  #
  #    #***************************************
  #    my $v = shift;
  #    return $v ? $v : 0;
  #  }

=head2 get_html

=cut

  sub get_html {
    my $self = shift;
    return <<'HTML';

<h1>[% DESCRIPTOR %] [% SEASON %]</h1>
<h2>Division: [% DIVISION %]</h2>
<p><a href="[% TABLES_INDEX_HREF %]">Return to Tables Index</a></p>

<table class="league_table">
<tr>
<th class="teamcol">Team</th>
<th>Played</th>
<th>Won</th>
<th>Tied</th>
<th>Lost</th>
<th>Batting Pts</th>
<th>Bowling Pts</th>
<th>Penalty Pts</th>
<th>Total</th>
<th>Average</th>
</tr>
[% TABLE_ROWS %]
</table>
<p class="timestamp">[% TIMESTAMP %]</p>
HTML
  }

=head2 get_row_html

=cut

  sub get_row_html {
    my $self = shift;

    return <<'HTML';
	<tr>
	<td class="teamcol">[% team %]</td>
	<td>[% played %]</td>
	<td>[% won %]</td>
	<td>[% tied %]</td>
	<td>[% lost %]</td>
	<td>[% battingpts %]</td>
	<td>[% bowlingpts %]</td>
	<td>[% penaltypts %]</td>
	<td>[% totalpts %]</td>
	<td>[% average %]</td>
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

    my $f = $self->get_table_html_full_filename;

    my $error = sub {
      my $err = shift;
      croak(
        ResultsSystem::Exception->new(
          "WRITE_ERR", "Unable to open file $f for writing. " . $err
        )
      );
    };

    open( my $FP, ">", $f ) || $error->($!);
    print $FP $line;
    close $FP;

    return 1;
  }

=head1 INTERNAL (PRIVATE) METHODS

=cut

=head2 set_table_html_full_filename

=cut

  sub set_table_html_full_filename {
    my ( $self, $v ) = @_;
    $self->{table_html_full_filename} = $v;
    return $self;
  }

=head2 get_table_html_full_filename

=cut

  sub get_table_html_full_filename {
    my ($self) = @_;
    croak( ResultsSystem::Exception->new( "MISSING", "table_html_full_filename not set." ) )
      if !$self->{table_html_full_filename};
    return $self->{table_html_full_filename};
  }

  1;

