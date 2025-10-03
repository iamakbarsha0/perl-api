package RebirthAPI::Routes::User;

use strict;
use warnings;
use Dancer2 appname => 'RebirthAPI::App';

use RebirthAPI::Models::User;
use RebirthAPI::Utils qw(
    ok
    error
    json_body_from_raw
);


# Gel all users
get '/api/users' => sub {
    my $users = RebirthAPI::Models::User::get_users();
    return ok({ users => $users });
};

# Get one user
get '/api/user/:id' => sub {
    my $id = route_parameters->get('id');
    my $user = RebirthAPI::Models::User::get_user($id);

    return $user ? ok({ user => $user }) : error("User not found");
};

# Create user
post '/api/user' => sub {
    my $payload = json_body_from_raw(request->body);
    my $user = RebirthAPI::Models::User::create_user($payload);
    return ok({ user => $user }, "User created successfully");
};

# Update user
put '/api/user/:id' => sub {
    my $id = route_parameters->get('id');
    my $payload = json_body_from_raw(request->body);
    my $user = RebirthAPI::Models::User::update_user($id, $payload);

    return $user ? ok({ user => $user }) : error("User not found or update failed");
};

# Delete user
del '/api/user/:id' => sub {
    my $id = route_parameters->get('id');
    my $deleted = RebirthAPI::Models::User::delete_user($id);

    return ok({ deleted => $deleted ? 1 : 0 });
};

1;

# # ------------------------
# # Update user
# # ------------------------
# put '/api/users/:id' => sub {
#     my $id      = route_parameters->get('id');
#     my $payload = json_body_from_raw(request->body);

#     my $user = RebirthAPI::Models::User::update_user($id, $payload);
#     print "[ROUTES] udpating user 222222 ----> " . Data::Dumper::Dumper($user) . "\n";
#     # [ROUTES] udpating user 222222 ----> $VAR1 = {
#     #       'name' => 'akbarsha88-3',
#     #       '_id' => bless( {
#     #                         'oid' => 'h�a��'{dQ'
#     #                       }, 'BSON::OID' ),
#     #       'akbarsha' => 'name',
#     #       'role' => 'user',
#     #       'updated_at' => '2025-09-25T11:30:03Z',
#     #       'created_at' => '2025-09-25T11:24:17Z',
#     #       'email' => 'akabrsha88-3@gmail.com'
#     #     };
    
#     unless ($user) {
#         status 404;
#         return error('User not found or update failed');
#     }
#     return ok({ user => normalize_bson($user) });
# };

# # ------------------------
# # Delete user
# # ------------------------
# del '/api/users/:id' => sub {
#     my $id      = route_parameters->get('id');
#     # $id =~ s/^\s+|\s+$//g if defined $id; # trim whitespace
#     # unless (defined $id && $id =~ /^[0-9a-fA-F]{24}\z/) {
#     #     status 400;
#     #     return error('Invalid id format');
#     # }
#     my $deleted = eval { RebirthAPI::Models::User::delete_user($id) };

#     if ($@) {
#         status 500;
#         return error('Failed to delete user');
#     }
#     return ok({ deleted => $deleted ? 1 : 0 });
# };

# 1;
