package RebirthAPI::Routes::User;

use strict;
use warnings;
use Dancer2 appname => 'RebirthAPI::App';
use JSON qw(decode_json);
use Data::Dumper ();

use RebirthAPI::Controllers::User;
use RebirthAPI::Utils qw(normalize_bson);

# Define the /api/users route
get '/api/users' => sub {
    my $res = RebirthAPI::Controllers::User::get_all_users();

    if (!$res->{success}) {
        status 500;
        return { success => 0, err => $res->{error} || 'Internal Server Error!'};
    }
    
    # Extract the users arrayref from the hashref
    my $users = $res->{users} || [];

    # Normalize BSON
    my @users_clean = map { normalize_bson($_) } @$users;
    
    # With serializer JSON enabled, return a Perl data structure
    return {
        success => $res->{success},
        users   => \@users_clean,
    };
};

# Get a single user by ID
get '/api/users/:id' => sub {
    my $id = route_parameters->get('id');
    my $res = RebirthAPI::Controllers::User::get_user_by_id($id);

    if (!$res->{success}) {
        status 500;
        return { success => 0, error => $res->{error} || 'Internal Server Error' };
    }

    if (!$res->{user}) {
        status 404;
        return { success => 0, error => 'User not found' };
    }

    my $user_clean = normalize_bson($res->{user});
    return { success => 1, user => $user_clean };
};

# Create a new user
post '/api/users' => sub {
    my $payload = eval { decode_json(request->body // '{}') } || {};
    my $res = RebirthAPI::Controllers::User::create_user($payload);

    if (!$res->{success}) {
        status 500; # adjust to 400 if you add validation errors
        return { success => 0, error => $res->{error} || 'Failed to create user' };
    }

    my $user_clean = $res->{user} ? normalize_bson($res->{user}) : undef;
    status 201;
    header 'Location' => "/api/users/" . ($res->{id} // '') if $res->{id};
    return { success => 1, user => $user_clean, id => $res->{id} };
};

# Update a user
put '/api/users/:id' => sub {
    my $id = route_parameters->get('id');
    my $payload = eval { decode_json(request->body // '{}') } || {};
    my $res = RebirthAPI::Controllers::User::update_user($id, $payload);

    warn "[Route] id ----> $id\n";
    warn "[Route] paylaod --> " . Data::Dumper::Dumper($payload);
    warn "[Route] res ----> " . Data::Dumper::Dumper($res);

    if (!$res->{success}) {
        status 500;
        return { success => 0, error => $res->{error} || 'Failed to update user' };
    }

    warn "[Route] res->{user} ----> " . Data::Dumper::Dumper($res->{user});
    if (!$res->{user}) {
        status 404;
        return { success => 0, error => 'User not found 2' };
    }

    my $user_clean = normalize_bson($res->{user});
    return { success => 1, user => $user_clean };
};

# Delete a user
del '/api/users/:id' => sub {
    my $id = route_parameters->get('id');
    my $res = RebirthAPI::Controllers::User::delete_user($id);

    if (!$res->{success}) {
        status 500;
        return { success => 0, error => $res->{error} || 'Failed to delete user' };
    }

    return { success => 1, deleted => $res->{deleted} };
};

1;