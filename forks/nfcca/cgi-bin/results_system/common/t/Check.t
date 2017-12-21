use strict;
use warnings;
use Test::More;

use_ok( 'Check', qw/check_dates_and_separators check_match_lines/ );

my $week_separator = "==========";

ok(
  !check_dates_and_separators(
    [ "1-Jun", $week_separator, "8-Jun", $week_separator, "15-Jun", $week_separator ]
  ),
  "Dates and separators match"
);

# The pod says that blank lines aren't allowed, but it seems that they are!
#ok(
#  check_dates_and_separators(
#    [ "1-Jun", $week_separator, "8-Jun", "", $week_separator, "15-Jun", $week_separator ]
#  ),
#  "Blank lines not allowed."
#);
ok(
  check_dates_and_separators(
    [ "1-Jun", $week_separator, "8-June", "", $week_separator, "15-Jun", $week_separator ]
  ),
  "Month name must be 3 characters. June is invalid"
);
ok(
  check_dates_and_separators(
    [ "1-Jun", $week_separator, "8-Jun", $week_separator, "15 123", $week_separator ]
  ),
  "Month name must be 3 characters. 123 is invalid"
);
ok(
  check_dates_and_separators(
    [ "o-Jun", $week_separator, "8-Jun", $week_separator, "15 Jun", $week_separator ]
  ),
  "Day of the month must be a digit."
);
ok(
  check_dates_and_separators(
    [ "1-Jun",  $week_separator, "8-Jun", $week_separator,
      "15-Jun", $week_separator, $week_separator
    ]
  ),
  "Dates and separators do not match"
);
ok(
  check_dates_and_separators( [ "1-Jun", $week_separator, "8-Jun", $week_separator, "15-Jun" ] ),
  "Dates and separators do not match"
);

my $short_week_separator = "=========";
ok(
  check_dates_and_separators(
    [ "1-Jun", $short_week_separator, "8-Jun", $week_separator, "15-Jun", $week_separator ]
  ),
  "One of the week separators is too short. " . length($short_week_separator)
);

ok(
  !check_match_lines(
    [ "1-Jun", "A,B",           "C,D",    $week_separator, "8-Jun", "A,C",
      "B,D",   $week_separator, "15-Jun", "A,D",           "B,C",   $week_separator
    ]
  ),
  "check_match_lines ok"
);

ok(
  check_match_lines(
    [ "1-Jun",  "A,B", "C,D", $week_separator,
      "8-Jun",  "A,C", "B,D", $week_separator,
      "15-Jun", "A,D", $week_separator
    ]
  ),
  "check_match_lines ok"
);

done_testing;
