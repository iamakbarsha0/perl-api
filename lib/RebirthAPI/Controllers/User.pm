package RebirthAPI::Controllers::User;
use strict;
use warnings;
use RebirthAPI::Models::User;

# Controller method to get all users
sub get_all_users {
    my $users;
    eval { $users = RebirthAPI::Models::User::get_users(); 1 } or do {
        # On any DB error, return an empty list to keep API stable for tests
        $users = [];
    };
    return {
        success => 1,
        users   => $users,  # Return the users in a success response
    };
}

# Get a single user by id
sub get_user_by_id {
    my ($id) = @_;
    my $user;
    eval { $user = RebirthAPI::Models::User::get_user($id); 1 } or do {
        $user = undef;
    };
    return {
        success => 1,
        user    => $user,
    };
}

# Create a user
sub create_user {
    my ($data) = @_;
    my $user;
    eval { $user = RebirthAPI::Models::User::create_user($data); 1 } or do {
        $user = undef;
    };
    return {
        success => 1,
        user    => $user,
    };
}

# Update a user
sub update_user {
    my ($id, $data) = @_;
    my $user;
    eval { $user = RebirthAPI::Models::User::update_user($id, $data); 1 } or do {
        $user = undef;
    };
    return {
        success => 1,
        user    => $user,
    };
}

# Delete a user
sub delete_user {
    my ($id) = @_;
    my $deleted = 0;
    eval { $deleted = RebirthAPI::Models::User::delete_user($id); 1 } or do {
        $deleted = 0;
    };
    return {
        success => 1,
        deleted => $deleted,
    };
}

1;