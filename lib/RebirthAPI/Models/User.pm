package RebirthAPI::Models::User;
use strict;
use warnings;
use BSON::OID;
use DateTime;
use Try::Tiny qw(try catch);
use Carp qw(confess);

use RebirthAPI::DB;

# Collection helper
sub _col {
    my $col;
    try {
        $col = RebirthAPI::DB::collection('users');
    }
    catch {
        confess "DB_ERROR: _col failed: $_";
    };
    return $col;
}

# Helper: build a BSON::OID from various id forms (BSON::OID, 24-hex string, or raw value)
sub _to_oid {
    my ($id) = @_;
    return $id if ref($id) && eval { $id->isa('BSON::OID') };
    # If it's a 24-hex string, convert to 12-byte binary then use 'value'
    if (defined($id) && $id =~ /^[0-9a-f]{24}$/i) {
        my $bytes = pack('H*', lc $id);
        return BSON::OID->new(value => $bytes);
    }
    return BSON::OID->new(value => $id)   if defined $id;
    return undef;
}

# Fetch all users from the database
sub get_users {
    my @docs;

    try {
        @docs = _col()->find->all;
        my $fetched = scalar @docs;
        print "[Model] get_users fetched via cursor: $fetched \n";
        return [ @docs ];
    }
    catch {
        confess "DB_ERROR: get_users failed: $_";
    };
}

# Fetch a single user by ID
sub get_user {
    my ($id) = @_;
    my $doc;
    try {
        my $oid = _to_oid($id);
        $doc = _col()->find_one({ _id => $oid });
    }
    catch {
        confess "DB_ERROR: get_user failed: $_";
    };
    return $doc;
}

# Create a new user document
sub create_user {
    my ($data) = @_;

    # Basic defaults
    $data->{role}       ||= 'user';
    $data->{created_at} ||= DateTime->now->iso8601() . 'Z';
    $data->{updated_at}   = DateTime->now->iso8601() . 'Z';
    try {
        my $res = _col()->insert_one($data);
        my $oid = $res->inserted_id;        # BSON::OID object
        $data->{_id} = $oid;                # attach inserted id directly
    }
    catch {
        confess "DB_ERROR: create_user failed: $_";
    };
    return $data;
}

# Update an existing user document
sub update_user {
    my ($id, $data) = @_;
    warn "[Model] data - 1 ----> $data";

    $data->{updated_at} = DateTime->now->iso8601() . 'Z';
    try {
        my $updateUser = _col()->update_one(
            { _id => _to_oid($id) },
            { '$set' => $data }
        );
        warn "[Model] updateUser ----> " . Data::Dumper::Dumper($updateUser);

    }
    catch {
        confess "DB_ERROR: update_user failed: $_";
    };
    warn "[Model] data - 2 ----> " . Data::Dumper::Dumper($data);
    # Return the updated document so callers receive a hashref
    my $updated = get_user($id);
    return $updated;
}

# Delete a user document
sub delete_user {
    my ($id) = @_;
    my $deleted = 0;
    try {
        my $res = _col()->delete_one({ _id => _to_oid($id) });
        $deleted = $res->deleted_count;
    }
    catch {
        confess "DB_ERROR: delete_user failed: $_";
    };
    return $deleted;
}

1;