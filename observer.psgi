use strict;
use warnings;

use Observer;

my $app = Observer->apply_default_middlewares(Observer->psgi_app);
$app;

