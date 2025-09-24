package RebirthAPI::App;
use strict;
use warnings;
use Dancer2;

# Load routes
use RebirthAPI::Routes::User;

our $VERSION = '0.1';

get '/' => sub {
    return { status => 'ok', message => 'Rebirth API PERL running' };
};

1;
