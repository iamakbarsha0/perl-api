package RebirthAPI::Routes::User;

use strict;
use warnings;

use Dancer2 appname => 'RebirthAPI::App';
use Data::Dumper ();

use RebirthAPI::Models::User;
use RebirthAPI::Utils qw(
    normalize_bson
    normalize_list
    ok
    error
    json_body_from_raw
);


# ------------------------
# Get all users
# ------------------------
get '/api/users' => sub {
    my $all_users = eval { RebirthAPI::Models::User::get_users() };
    if ($@) {
        status 500;
        return error('Failed to fetch users');
    }
    return ok({ users => normalize_list($all_users) }, "User created successfully");
};

# ------------------------
# Get one user by ID
# ------------------------
get '/api/users/:id' => sub {
    my $id   = route_parameters->get('id');
    my $user = eval { RebirthAPI::Models::User::get_user($id) };

    print "[ROUTES] /api/users/:id - user ----> " . Data::Dumper::Dumper($user) . "\n";
    # [ROUTES] /api/users/:id - user ----> $VAR1 = {
    #       '_id' => bless( {
    #                         'oid' => 'h�$j�'�q'
    #                       }, 'BSON::OID' ),
    #       'name' => 'akbarsha77',
    #       'updated_at' => '2025-09-25T11:01:56Z',
    #       'created_at' => '2025-09-25T11:01:56Z',
    #       'email' => 'akabrsha77@gmail.com',
    #       'akbarsha' => 'name',
    #       'role' => 'user'
    #     };

    if ($@) {
        status 500;
        return error('Failed to fetch user');
    }
    unless ($user) {
        status 404;
        return error('User not found');
    }
    return ok({ user => normalize_bson($user) });
};

# ------------------------
# Update user
# ------------------------
put '/api/users/:id' => sub {
    my $id      = route_parameters->get('id');
    my $payload = json_body_from_raw(request->body);

    my $user = RebirthAPI::Models::User::update_user($id, $payload);
    print "[ROUTES] udpating user 222222 ----> " . Data::Dumper::Dumper($user) . "\n";
    # [ROUTES] udpating user 222222 ----> $VAR1 = {
    #       'name' => 'akbarsha88-3',
    #       '_id' => bless( {
    #                         'oid' => 'h�a��'{dQ'
    #                       }, 'BSON::OID' ),
    #       'akbarsha' => 'name',
    #       'role' => 'user',
    #       'updated_at' => '2025-09-25T11:30:03Z',
    #       'created_at' => '2025-09-25T11:24:17Z',
    #       'email' => 'akabrsha88-3@gmail.com'
    #     };
    
    unless ($user) {
        status 404;
        return error('User not found or update failed');
    }
    return ok({ user => normalize_bson($user) });
};

# ------------------------
# Delete user
# ------------------------
del '/api/users/:id' => sub {
    my $id      = route_parameters->get('id');
    # $id =~ s/^\s+|\s+$//g if defined $id; # trim whitespace
    # unless (defined $id && $id =~ /^[0-9a-fA-F]{24}\z/) {
    #     status 400;
    #     return error('Invalid id format');
    # }
    my $deleted = eval { RebirthAPI::Models::User::delete_user($id) };

    if ($@) {
        status 500;
        return error('Failed to delete user');
    }
    return ok({ deleted => $deleted ? 1 : 0 });
};

1;
