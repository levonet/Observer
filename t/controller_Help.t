use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Observer';
use Observer::Controller::Help;

ok( request('/help/confsnmp')->is_success, 'Request should succeed' );
done_testing();
