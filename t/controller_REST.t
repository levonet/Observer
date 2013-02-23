use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Observer';
use Observer::Controller::REST;

ok( request('/rest')->is_success, 'Request should succeed' );
done_testing();
