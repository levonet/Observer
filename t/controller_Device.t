use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Observer';
use Observer::Controller::Device;

ok( request('/device')->is_success, 'Request should succeed' );
done_testing();
