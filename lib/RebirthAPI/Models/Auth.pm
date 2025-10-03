package RebirthAPI::Models::Auth;

use strict;
use warnings;

use Carp qw(confess);
use Try::Tiny;
use DateTime;
use RebirthAPI::DB;
use Data::Dumper;
use RebirthAPI::Utils qw(
    ok
    error
    normalize_bson
);

sub auth_login {
    my ($data) = @_;
    my $dbh = RebirthAPI::DB::dbh();

    my $sql = q{
        SELECT * FROM users WHERE email = ? AND name = ?
    };

    my $user = $dbh->selectrow_hashref($sql, undef, $data->{email}, $data->{name});

    if ($user) {
        return {
            success => 1,
            user    => $user,
        };
    } else {
        return {
            success => 0,
            error   => "Invalid credentials",
        };
    }
}

1;