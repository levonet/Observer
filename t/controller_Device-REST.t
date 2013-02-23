use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Observer';
use Observer::Controller::Device::REST;

ok( request('/device/rest')->is_success, 'Request should succeed' );
done_testing();
