use strict;
use warnings;
use Test::More;


BEGIN {
    use_ok 'Observer';
    use_ok 'Observer::View::HTML';
}

ok my $view = Observer->view('HTML'), 'Get HTML view object';

done_testing();
