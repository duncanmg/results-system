package Check;

use strict;
use warnings;

use File::Slurp qw/slurp/;
use List::MoreUtils qw/ uniq /;
use Regexp::Common qw /whitespace/;
use Params::Validate qw/:all/;
use Data::Dumper;

use parent qw/Exporter/;
our @EXPORT_OK =
  qw/ check_dates_and_separators check_match_lines check filter_invalid_match_lines /;

my $week_separator_pattern = "^={10,}[,\\s\\n]*\$";
my $date_pattern           = "^[0-9]{1,2}-[A-Z][a-z]{2}[,\\n\\s]*\$";
my $match_pattern          = '^[ \w\'&]+,[ \w\'&]+\s*$';

=head1 checkfixtures.pl

Script which checks for simple errors in the .csv files which contain the fixtures for a division. Any errors
found are sent to the standard output.

perl checkfixtures.pl <filename>

=cut

=head2 Example Of Correct Format

 10-May
 Australia,England
 West Indies,New Zealand
 South Africa,India
 Havant,Denmead
 ==========,
 17-May
 Australia,Denmead
 England,Havant
 New Zealand,South Africa
 India,West Indies
 ==========,

=cut

=head2 Rules

The file must start with a date line and end with a week separator. If the division starts after one of the other divisions,
blank weeks should not be inserted. The empty week should be omitted.

=cut

=head2 Checks Performed

=over 5

=item Format of week separator

The week separator must be on a new line. It must be ten or more = signs followed by a comma
then by a carriage return.

=item Format of date

The date must be on the line after the week separator. It must be 2 digits followed by a hyphen, followed
by a capital letter and 2 more digits then a carriage return. No comma.

=item Number of week separators and number of date lines.

These must be equal and must not be zero.

=back

=cut

=head2 Functions

=head3 check_dates_and_separators

=cut

# ********************************************************
sub check_dates_and_separators {

  # ********************************************************
  my ($lines) = validate_pos( @_, { type => ARRAYREF } );
  my $err = 0;

  my $num_week_separators = grep { $_ =~ m/$week_separator_pattern/x } @$lines;

  my $num_date_lines = grep { $_ =~ m/$date_pattern/x } @$lines;

  if ( $num_week_separators != $num_date_lines ) {
    print "File does not have the same number of week separators as date lines.\n";
    print "Week separators: $num_week_separators \n";
    print "Date lines: $num_date_lines \n";
    $err = 1;
  }
  if ( $num_week_separators == 0 || $num_date_lines == 0 ) {
    print "Neither the number of week separators nor the number of date lines can be zero.\n";
    print "Week separators: $num_week_separators \n";
    print "Date lines: $num_date_lines \n";
    $err = 1;
  }
  return $err;
}

=head3 check_match_lines

=cut

# ********************************************************
sub check_match_lines {

  # ********************************************************
  my ( $lines, $count_games_played ) =
    validate_pos( @_, { type => ARRAYREF }, { type => SCALAR | UNDEF, default => 1 } );
  my $err = 0;

  # Eliminate the date lines and line separators. Anything left should be a fixture.
  my @match_lines = grep { $_ !~ m/(?:$week_separator_pattern)|(?:$date_pattern)/x } @$lines;

  my @invalid_match_lines = @{ filter_invalid_match_lines( \@match_lines ) };
  if ( scalar(@invalid_match_lines) > 0 ) {
    print "The following match lines are invalid.\n";
    print Dumper @invalid_match_lines;
    $err = 1;
  }

  my @num_commas = grep { $_ =~ m/\s*,\s*$/x } @match_lines;

  my $team_counts = {};
  foreach my $t (@match_lines) {
    my @bits = split( /,/x, $t );
    $bits[0] =~ s/$RE{ws}{crop}//xg;    # Delete surrounding whitespace
    $bits[1] =~ s/$RE{ws}{crop}//xg;    # Delete surrounding whitespace

    $team_counts->{ $bits[0] } = 0 if !$team_counts->{ $bits[0] };
    $team_counts->{ $bits[1] } = 0 if !$team_counts->{ $bits[1] };
    $team_counts->{ $bits[0] }++;
    $team_counts->{ $bits[1] }++;
  }

  return $err if !$count_games_played;

  # Now find out how many matches each team plays. They should all play the same number.
  if ( scalar( uniq( sort( map { $team_counts->{$_} } keys %$team_counts ) ) ) > 1 ) {
    print "The teams do not all play the same number of matches.\n";
    local $Data::Dumper::Sortkeys = 1;
    print Dumper $team_counts;
    $err = 1;
  }
  return $err;
}

=head3 filter_invalid_match_lines

Accept an array ref and return an array ref of those lines which
do NOT contain a valid match.

=cut

sub filter_invalid_match_lines {
  my ($lines) = validate_pos( @_, { type => ARRAYREF } );
  return [ grep { $_ !~ m/$match_pattern/x } @$lines ];
}

=head3 check

=cut

# ********************************************************
sub check {

  # ********************************************************
  my ( $file, $opts ) = validate_pos( @_, { type => SCALAR }, { type => HASHREF } );
  my $err = 0;

  my $lines = [ slurp $file ];

  $err = check_dates_and_separators($lines);
  if ( $err == 0 ) {
    $err = check_match_lines( $lines, $opts->{count_games_played} );
  }
  return $err;

}

1;
