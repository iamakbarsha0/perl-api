package RebirthAPI::Models::User;
use strict;
use warnings;
use BSON::OID;
use DateTime;
use Try::Tiny qw(try catch);
use Carp qw(confess);
use Data::Dumper ();

use RebirthAPI::DB;

# ------------------------
# Collection helper
# ------------------------
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

# ------------------------
# Helper: normalize id (CORRECT APPROACH)
# ------------------------
sub _to_oid {
    my ($id) = @_;
    return undef unless defined $id;
    return undef unless $id =~ /^[0-9a-fA-F]{24}$/;
    
    # Convert hex string to 12-byte binary data
    my $binary = pack("H*", $id);
    
    # Create BSON::OID from binary data (not hex string!)
    return BSON::OID->new( oid => $binary );
}

# ------------------------
# Fetch all users
# ------------------------
sub get_users {
    my @docs;
    try {
        @docs = _col()->find->all;
        print "[Model] get_users fetched via cursor: " . scalar(@docs) . "\n";
        # [Model] get_users fetched via cursor: 97
        return \@docs;
    }
    catch {
        confess "DB_ERROR: get_users failed: $_";
    };
}

# ------------------------
# Fetch single user by id
# ------------------------
sub get_user {
    my ($id) = @_;
    my $doc;

    try {
        print "[MODEL] id input ----> $id\n";
        # [MODEL] id input ----> 68d52124a46acc27e28ae271
        
        # Use the consistent _to_oid helper
        my $oid = _to_oid($id);
        print "[MODEL] converted oid ----> $oid\n";
        # [MODEL] converted oid ----> 68d52124a46acc27e28ae271
        
        if ($oid) {
            $doc = _col()->find_one({ _id => $oid });
            print "[MODEL] found with BSON::OID ----> " . ($doc ? "YES" : "NO") . "\n";
            # [MODEL] found with BSON::OID ----> YES
        }
        
        # Fallback for legacy docs with string ids (if needed)
        if (!$doc && defined $id) {
            $doc = _col()->find_one({ _id => $id });
            print "[MODEL] fallback with string id ----> " . ($doc ? "YES" : "NO") . "\n";
            # [MODEL] final doc ----> $VAR1 = {
            #           '_id' => bless( {
            #                             'oid' => 'h�$j�'�q'
            #                           }, 'BSON::OID' ),
            #           'name' => 'akbarsha77',
            #           'updated_at' => '2025-09-25T11:01:56Z',
            #           'created_at' => '2025-09-25T11:01:56Z',
            #           'email' => 'akabrsha77@gmail.com',
            #           'akbarsha' => 'name',
            #           'role' => 'user'
            #         };
        }
        
        print "[MODEL] final doc ----> " . Data::Dumper::Dumper($doc) . "\n";
    }
    catch {
        confess "DB_ERROR: get_user failed: $_";
    };

    return $doc;
}

# ------------------------
# Create user
# ------------------------
sub create_user {
    my ($data) = @_;

    # prevent duplicate email
    my $existing = _col()->find_one({ email => $data->{email} });
    if ($existing) {
        return {
            success => 0,
            code    => 'EMAIL_EXISTS',
            message => 'User with this email already exists'
        };
    }

    $data->{role}       ||= 'user';
    $data->{created_at} ||= DateTime->now->iso8601() . 'Z';
    $data->{updated_at}   = DateTime->now->iso8601() . 'Z';

    my $res = eval {
        my $r = _col()->insert_one($data);
        $data->{_id} = $r->inserted_id;
        return $data;
    };

    if ($@) {
        return {
            success => 0,
            code    => 'DB_ERROR',
            message => "Failed to create user: $@"
        };
    }

    return { success => 1, data => $res };
}

# ------------------------
# Update user
# ------------------------
sub update_user {
    my ($id, $data) = @_;

    # Use the consistent _to_oid helper
    my $oid = _to_oid($id);
    return undef unless $oid;

    print "\n[DEBUG] Incoming id string  --> $id\n";
    # [DEBUG] Incoming id string  --> 68d52661cb41f0277bab6451
    print "[DEBUG] Converted BSON::OID --> $oid\n";
    # [DEBUG] Converted BSON::OID --> 68d52661cb41f0277bab6451

    # Prepare fields to update
    my %update;
    for my $field (qw(name email)) {
        $update{$field} = $data->{$field} if exists $data->{$field};
    }
    $update{updated_at} = DateTime->now->iso8601() . 'Z';

    my $res;
    try {
        $res = _col()->update_one(
            { _id => $oid },
            { '$set' => \%update }
        );
        
        print "[DEBUG] Update matched_count --> " . $res->matched_count . "\n";
        # [DEBUG] Update matched_count --> 1
        print "[DEBUG] Update modified_count --> " . $res->modified_count . "\n";
        # [DEBUG] Update modified_count --> 1
        
        # Fallback for legacy docs with string ids (if needed)
        if (!$res->matched_count && defined $id) {
            print "[DEBUG] Trying fallback with string id\n";
            $res = _col()->update_one(
                { _id => $id },
                { '$set' => \%update }
            );
            print "[DEBUG] Fallback matched_count --> " . $res->matched_count . "\n";
        }
        
        return undef unless $res && $res->matched_count;
    }
    catch {
        confess "DB_ERROR: update_user failed: $_";
    };

    # Fetch and return the updated doc using the same OID
    my $doc = _col()->find_one({ _id => $oid });
    
    # Fallback if needed
    if (!$doc && defined $id) {
        $doc = _col()->find_one({ _id => $id });
    }
    
    return $doc;
}

# ------------------------
# Delete user
# ------------------------
sub delete_user {
    my ($id) = @_;
    my $deleted = 0;

    try {
        my $oid = _to_oid($id);
        if ($oid) {
            my $res = _col()->delete_one({ _id => $oid });
            $deleted = $res->deleted_count;
        }
        
        # Fallback for legacy docs with string ids
        if (!$deleted && defined $id) {
            my $res2 = _col()->delete_one({ _id => $id });
            $deleted = $res2->deleted_count;
        }
    }
    catch {
        confess "DB_ERROR: delete_user failed: $_";
    };

    return $deleted;
}

1;