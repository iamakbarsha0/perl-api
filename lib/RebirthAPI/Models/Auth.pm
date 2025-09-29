package RebirthAPI::Models::Auth;

use strict;
use warnings;

use Carp qw(confess);
use Try::Tiny;
use DateTime;
use RebirthAPI::DB;
use Data::Dumper ();
use RebirthAPI::Utils qw(
    ok
    error
    normalize_bson
);

sub _col {
    my $col;
    try {
        $col = RebirthAPI::DB::collection('users');
        print "[Auth::_col] Got collection: $col\n";
    }
    catch {
        confess "DB_ERROR: _col failed: $_";
    };
    die "_col returned undef!" unless $col;
    return $col;
}

sub auth_login {
    my ($data) = @_;

    print "\n data->{email} ---> $data->{email} \n";
    print "\n data->{password} ---> $data->{password} \n";

    # find user if exisits in DB
    my $query = { 
        email => $data->{email},
        password => $data->{password} 
    };
    print "\n[Auth::auth_login] Query: " . Data::Dumper::Dumper($query);
    
    my $existing = _col()->find_one($query);
    print "\n existing ---> $existing \n";
    
    if ($existing) {
        return {
            success => 1,
            user    => $existing,
            message => "Welcome user",
        };
    } else {
        return {
            success => 0,
            error   => "INVALID_CREDS",
            message => "Invalid Credentials! Please check!",
        };
    }
}

sub create_user {
    my ($data) = @_;

    # prevent duplicate email
    my $existing = _col()->find_one({ email => $data->{email} });
    if ($existing) {
        return error("User with this email already exists");
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
        return error("Failed to create user: $@");
    }

    return ok({ user => normalize_bson($res) }, "User created successfully");
}

1;