use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Observer';
use Observer::Controller::Device::REST;

ok( request('/device/rest/hostitem_id/0')->is_success, 'Request should succeed' );
done_testing();
