# ****************************************************************************
#
# Name: checkfixtures.pl
#
# Function: Check for common errors in the fixtures files. Are there the same number
#       of lines separators as week separator lines? Do all the teams play the same
#       number of matches?
#
# 1.0  30 Jun 07 - Initial version
# 1.1  23 Feb 08 - Patterns improved. POD added.
# 1.2  27 Apr 08 - main() added. Can now check a whole directory.
#
# ****************************************************************************

use Slurp;
use List::MoreUtils qw/ uniq /;
use Regexp::Common qw /whitespace/;

print $ARGV[0] . "\n";

$week_separator_pattern = "^={10,}[,\\s\\n]*\$";
$date_pattern = "[0-9]{1,2}[- ][A-Z][a-z]{2}[\\n\\s,]*\$";

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

# ********************************************************
sub check_dates_and_separators {
# ********************************************************
  my $file = shift;
  my $ref = shift;
  my @lines = @$ref;
  my $err = 0;

  my $num_week_separators = grep( /$week_separator_pattern/, @lines );

  my $num_date_lines = grep( /$date_pattern/, @lines );

  if ( $num_week_separators != $num_date_lines ) {
    print "$file does not have the same number of week separators as date lines.\n";
    print "Week separators: $num_week_separators \n";
    print "Date lines: $num_date_lines \n";
    $err = 1;
  }
  if ( $num_week_separators == 0 || $num_date_lines == 0 ) {
    print "$file.  Neither the number of week separators  or the number of date lines can be zero.\n";
    print "Week separators: $num_week_separators \n";
    print "Date lines: $num_date_lines \n";
  }
  return $err;
}

# ********************************************************
sub check_match_lines {
# ********************************************************
  my $file = shift;
  my $ref = shift;
  my @lines = @$ref;
  my @teams;
  my $err = 0;

  # Eliminate the date lines and line separators. Anything left should be a fixture.
  my @match_lines = grep( ! /($week_separator_pattern)|($date_pattern)/, @lines );
  
  my @num_commas = grep( /\s*,\s*$/, @match_lines );
  if ( scalar( @num_commas ) > 0 ) {
    print "Match lines must not end in commas.\n";
    foreach my $c ( @num_commas ) {
      print "$c";
    }  
  }
  
  foreach my $t ( @match_lines ) {
    my @bits = split( /,/, $t );
    $bits[0] =~ s/$RE{ws}{crop}//g;           # Delete surrounding whitespace
    # $bits[0] should be the home team.
    push @teams, $bits[0];
  }
  @teams = sort @teams;
  @teams = uniq @teams;

  # @teams should now be a sorted list of the teams in the division.
  # Now find out how many matches each team plays. They should all play the same number.

  my $correct_matches = -1;
  foreach my $t ( @teams ) {

    my $team_count = 0;
    # Escape any brackets in the search string.
    $t =~ s/\(/\\\(/g;
    $t =~ s/\)/\\\)/g;

    foreach my $m ( @match_lines ) {

      if ( $m =~ m/(^$t\s*,)|(,\s*$t\s*$)/ ) {
        $team_count++;
      }

    }

   if ( ( $correct_matches >= 0 ) && ( $correct_matches != $team_count ) ) {
     print "$t play $team_count matches. The correct number is $correct_matches.\n";
     $err = 1;
   }
   $correct_matches = $team_count;

  }
  return $err;
}

# ********************************************************
sub check_file {
# ********************************************************
  my $file = shift;
  my @lines;
  my $err = 0;
  
  if ( ! -f $file ) {
    print "$file does not exist.\n";
    $err = 1;
  }
  else {
    @lines = slurp( $file );
  }
  if ( $err == 0 ) {
    $err = check_dates_and_separators( $file, \@lines );
  }
  if ( $err == 0 ) {
    $err = check_match_lines( $file, \@lines );
  }
  return $err;
  
}

=head2 main()

Accepts one argument which can be either a file or a directory.
If it is a directory then all the files in the directory are checked,
if not then only the one file is checked.

=cut

# ********************************************************
sub main {
# ********************************************************
  my $file = shift;
  my $FP;
  
  if ( -d $file ) {
    if ( opendir( $FP, $file ) ) {
      my @fl = readdir( $FP );
      close $FP;
      foreach my $f ( @fl ) {
        if ( $f =~ m/\.$/ ) {
          next;
        }  
        push @file_list, "$file/$f";
      }
    }
    else {
      print "Unable to open directory $file.\n";
      $err = 1;
    }  
  }
  else {
    push @file_list, $file;
  }  
  
  foreach my $f ( @file_list ) {
    if ( check_file( $f ) ) {
      print "Not OK: $f\n";
      $err = 1;
    }
    else {
      print "File OK: $f\n";
    }  
  }
  
  return $err;
}

main( $ARGV[0] );
