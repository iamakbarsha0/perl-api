package RebirthAPI::App;
use strict;
use warnings;
use Dancer2;

# Load routes
use RebirthAPI::Routes::User;
use RebirthAPI::Routes::Auth;

our $VERSION = '0.2';

get '/' => sub {
    return { status => 'ok', message => 'Rebirth API PERL running' };
};

1;
