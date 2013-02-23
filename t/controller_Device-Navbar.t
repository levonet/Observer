use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Observer';
use Observer::Controller::Device::Navbar;

ok( request('/device/navbar')->is_success, 'Request should succeed' );
done_testing();
