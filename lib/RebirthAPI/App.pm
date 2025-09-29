package RebirthAPI::App;
use strict;
use warnings;
use Dancer2;

# Load routes
use RebirthAPI::Routes::User;
use RebirthAPI::Routes::Auth;

our $VERSION = '0.2';

# Allow CORS for frontend running on localhost:3000
hook before => sub {
    response_header 'Access-Control-Allow-Origin'  => 'http://localhost:3000';
    response_header 'Access-Control-Allow-Headers' => 'Content-Type, Authorization';
    response_header 'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS';
};

# Handle preflight requests
options qr{.*} => sub {
    status 200;
    return '';
};

get '/' => sub {
    return { status => 'ok', message => 'Rebirth API PERL running' };
};

1;


# package RebirthAPI::App;
# use strict;
# use warnings;
# use Dancer2;
# use Dancer2::Plugin::CORS;

# # Load routes
# use RebirthAPI::Routes::User;
# use RebirthAPI::Routes::Auth;

# our $VERSION = '0.2';

# # Allow CORS for frontend running on localhost:3000
# # hook before => sub {
# #     header 'Access-Control-Allow-Origin'  => 'http://localhost:3000';
# #     header 'Access-Control-Allow-Headers' => 'Content-Type, Authorization';
# #     header 'Access-Control-Allow-Methods' => 'GET, POST, PUT, DELETE, OPTIONS';
# # };

# # # Handle preflight requests
# # options qr{.*} => sub {
# #     status 200;
# #     return '';
# # };


# set cors_origins => '*';
# set cors_headers => 'Content-Type, Authorization';
# set cors_methods => 'GET, POST, PUT, DELETE, OPTIONS';

# get '/' => sub {
#     return { status => 'ok', message => 'Rebirth API PERL running' };
# };

# 1;
