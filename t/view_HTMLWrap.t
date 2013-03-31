use strict;
use warnings;
use Test::More;


BEGIN {
    use_ok 'Observer';
    use_ok 'Observer::View::HTMLWrap';
}

ok my $view = Observer->view('HTMLWrap'), 'Get HTMLWrap view object';

done_testing();
