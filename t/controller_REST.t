use strict;
use warnings;
use Test::More;

use Catalyst::Test 'Observer';
use Observer::Controller::REST;
use HTTP::Request::Common;
use JSON::Any;

my $data = '{"test/bool":true}';
my $res = request(
    POST '/rest/settings',
    'X-Requested-With' => 'XMLHttpRequest',
    Content_Type => 'application/json',
    Content => $data,
);

my $content = $res->content;
my $expected = '{"status":"set"}';
is_deeply ( $content, $expected);

#$data = '"test/bool"';
#$res = request(
#    DELETE '/rest/settings', [  ]
#    'X-Requested-With' => 'XMLHttpRequest',
#    Content_Type => 'application/json',
#    Content => $data,
#);
#
#$content = $res->content;
#warn $content;
#$expected = '{"status":"del"}';
#is_deeply ( $content, $expected);

done_testing();
