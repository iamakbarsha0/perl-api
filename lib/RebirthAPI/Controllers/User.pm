package RebirthAPI::Controllers::User;
use strict;
use warnings;
use RebirthAPI::Models::User;
use Data::Dumper ();

use Try::Tiny qw(try catch);
use Carp qw(confess);

# Controller method to get all users
sub get_all_users {
    my ($users, $err);
    try { 
        $users = RebirthAPI::Models::User::get_users();
        # my $count = ref $users eq 'ARRAY' ? scalar(@$users) : 0;
        # print "\n[Controller] get_all_users: fetched $count users\n";
        print "\n[Controller] get_all_users->users: $users\n";
    } 
    catch {
        $err = $_;
        # On any DB error, return an empty list to keep API stable for tests
        $users = [];
        warn "[Controller] get_all_users: $err \n";
    };
    return  $err ? {
        success => 0,
        error   => 'Failed to fetch users',
        users   => $users,
    } : {
        success => 1,
        users   => $users,  # Return the users in a success response
    };
}

# Get a single user by id
sub get_user_by_id {
    my ($id) = @_;
    my ($user, $err);
    try {
        $user = RebirthAPI::Models::User::get_user($id);
    }
    catch {
        $err = $_;
        warn "[Controller] get_user_by_id: $err\n";
    };
    return $err ? {
        success => 0,
        error   => 'Failed to fetch user',
        user    => undef,
    } : {
        success => 1,
        user    => $user,
    };
}

# Create a user
sub create_user {
    my ($data) = @_;
    my ($user, $err);
    try {
        $user = RebirthAPI::Models::User::create_user($data);
    }
    catch {
        $err = $_;
        warn "[Controller] create_user: $err\n";
    };
    if ($err) {
        return {
            success => 0,
            error   => 'Failed to create user',
            user    => undef,
            id      => undef,
        };
    }

    # Extract a friendly string id if available
    my $id;
    if ($user && exists $user->{_id}) {
        my $oid = $user->{_id};
        if (ref($oid) && eval { $oid->can('to_string') }) {
            $id = $oid->to_string;
        } else {
            $id = $oid;
        }
    }

    return {
        success => 1,
        user    => $user,
        id      => $id,
    };
}

# Update a user
sub update_user {
    my ($id, $data) = @_;
    my ($user, $err);
    try {
        $user = RebirthAPI::Models::User::update_user($id, $data);
        print "[Controller] id ---> $id";
        print "[Controller] data ---> $data";
    }
    catch {
        $err = $_;
        warn "[Controller] update_user: $err\n";
    };
    warn "[Controller] Data::Dumper::Dumper($user) ---> " . Data::Dumper::Dumper($user);
    return $err ? {
        success => 0,
        error   => 'Failed to update user',
        user    => undef,
    } : {
        success => 1,
        user    => $user,
    };
}

# Delete a user
sub delete_user {
    my ($id) = @_;
    my ($deleted, $err) = (0, undef);
    try {
        $deleted = RebirthAPI::Models::User::delete_user($id);
    }
    catch {
        $err = $_;
        warn "[Controller] delete_user: $err\n";
    };
    return $err ? {
        success => 0,
        error   => 'Failed to delete user',
        deleted => 0,
    } : {
        success => 1,
        deleted => $deleted,
    };
}

1;