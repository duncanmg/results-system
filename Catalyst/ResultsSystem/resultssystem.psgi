use strict;
use warnings;

use ResultsSystem;

my $app = ResultsSystem->apply_default_middlewares(ResultsSystem->psgi_app);
$app;

