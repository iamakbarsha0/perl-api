package RebirthAPI::Routes::User;

use strict;
use warnings;
use Dancer2 appname => 'RebirthAPI::App';
use JSON qw(decode_json);

use RebirthAPI::Controllers::User;

# Define the /api/users route
get '/api/users' => sub {
    my $data = RebirthAPI::Controllers::User::get_all_users();

    # With serializer JSON enabled, return a Perl data structure
    return {
        success => $data->{success},
        users   => $data->{users},
    };
};

# Get a single user by ID
get '/api/users/:id' => sub {
    my $id = route_parameters->get('id');
    my $data = RebirthAPI::Controllers::User::get_user_by_id($id);
    return {
        success => $data->{success},
        user    => $data->{user},
    };
};

# Create a new user
post '/api/users' => sub {
    my $payload = eval { decode_json(request->body // '{}') } || {};
    my $data = RebirthAPI::Controllers::User::create_user($payload);
    status 201 if $data->{user};
    return {
        success => $data->{success},
        user    => $data->{user},
    };
};

# Update a user
patch '/api/users/:id' => sub {
    my $id = route_parameters->get('id');
    my $payload = eval { decode_json(request->body // '{}') } || {};
    my $data = RebirthAPI::Controllers::User::update_user($id, $payload);
    return {
        success => $data->{success},
        user    => $data->{user},
    };
};

# Delete a user
del '/api/users/:id' => sub {
    my $id = route_parameters->get('id');
    my $data = RebirthAPI::Controllers::User::delete_user($id);
    return {
        success => $data->{success},
        deleted => $data->{deleted},
    };
};

1;