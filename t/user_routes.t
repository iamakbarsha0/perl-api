use strict;
use warnings;
use Test::More;
use Plack::Test;
use HTTP::Request::Common qw(GET);
use JSON;

use lib 'lib';
use RebirthAPI::App;

plan tests => 1;

my $app = RebirthAPI::App->to_app;  # use Dancer2's PSGI app
my $test = Plack::Test->create($app);

my $res = $test->request(GET '/api/users');
my $content = $res->content;

my $json;
eval { $json = decode_json($content) };
if ($@) {
    diag("Failed to decode JSON: $@");
    diag("Raw response: $content");
    die $@;
}

is($json->{success}, 1, '[GET /api/users] successful');