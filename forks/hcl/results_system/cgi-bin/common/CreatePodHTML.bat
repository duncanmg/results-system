echo hello %1
REM echo goodbye
REM call pod2html -title "Fixtures.pm" -css "gen_styles.css" -outfile "..\..\documentation\Fixtures.htm" -infile Fixtures.pm
REM echo here
call pod2html -title "%1.pm" -css "gen_styles.css" -outfile "..\..\documentation\%1.htm" -infile %1.pm
REM echo there