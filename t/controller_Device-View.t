use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Observer';
use Observer::Controller::Device::View;

ok( request('/device/view')->is_success, 'Request should succeed' );
done_testing();
