package RebirthAPI::Models::User;
use strict;
use warnings;

use DateTime;
use Fey::Literal;
use Fey::SQL::Select;

use Fey::Schema;
use Fey::SQL;

use RebirthAPI::DB;

# ------------------------
# Fetch all users
# ------------------------
sub get_users {
    my $schema = RebirthAPI::DB::schema();
    my $users = $schema->table('users');

    my $select = Fey::SQL::Select->new();
    $select->select($users->columns)->from($users);

    my $dbh = RebirthAPI::DB::dbh();
    print "dbh - $dbh\n";

    my $sth = $dbh->prepare($select->sql($dbh));
    $sth->execute();

    return $sth->fetchall_arrayref({});
}


# ------------------------
# Fetch single user by id
# ------------------------
sub get_user {
    my ($id) = @_;

    # Get the schema and table
    my $schema = RebirthAPI::DB::schema();
    my $users  = $schema->table('users');

    # Build the SQL SELECT statement
    my $select = Fey::SQL::Select->new();
    $select->select($users->columns)
           ->from($users)
           ->where($users->column('id'), '=', Fey::Literal->new_from_scalar($id));
        #    ->where($users->column('id'), '=', Fey::Literal->new({ value => $id }));

    # Prepare and execute the statement
    my $dbh = RebirthAPI::DB::dbh();
    my $sth = $dbh->prepare($select->sql($dbh));
    $sth->execute();

    # Return the first row as a hashref
    return $sth->fetchrow_hashref();
}
# sub get_user {
#     my ($id) = @_;
#     my $dbh = RebirthAPI::DB::dbh();
#     my $sth = $dbh->prepare("SELECT * FROM users WHERE id = ?");
#     $sth->execute($id);

#     return $sth->fetchrow_hashref();
# }

sub create_user {
    my ($data) = @_;
    my $dbh = RebirthAPI::DB::dbh();
    my $now = DateTime->now->strftime('%Y-%m-%d %H:%M:%S');
    
    my $sql = q{
        INSERT INTO users (name, email, role, created_at, updated_at)
        VALUES (?, ?, ?, ?, ?)
    };
    
    $dbh->do( 
        $sql,
        undef,
        $data->{name},
        $data->{email},
        $data->{role} // 'user',
        $now,
        $now
    );
    
    my $id = $dbh->{mysql_insertid};
    
    return {
        id         => $id,
        name       => $data->{name},
        email      => $data->{email},
        role       => $data->{role} // 'user',
        created_at => $now,
        updated_at => $now,
    };
}
# sub create_user {
#     my ($data) = @_;
#     my $dbh = RebirthAPI::DB::dbh();
#     my $now = DateTime->now->strftime('%Y-%m-%d %H:%M:%S');
#     my $sth = $dbh->prepare("INSERT INTO users (name, email, role, created_at, updated_at) VALUES (?, ?, ?, ?, ?)");
#     $sth->execute($data->{name}, $data->{email}, $data->{role} // 'user', $now, $now);
#     my $id = $dbh->{mysql_insertid};
#     return {
#         id => $id,
#         name => $data->{name},
#         email => $data->{email},
#         role => $data->{role} // 'user',
#         created_at => $now,
#         updated_at => $now,
#     };
# }
# ------------------- NOT WORKING -------------------
# ------------------- NOT WORKING -------------------
# sub create_user {
#     my ($data) = @_;
#     my $dbh = RebirthAPI::DB::dbh();
#     my $schema = RebirthAPI::DB::schema();
#     my $now = DateTime->now->strftime('%Y-%m-%d %H:%M:%S');
    
#     my $users = $schema->table('users');
    
#     my $insert = Fey::SQL->new_insert()->into($users);
#     $insert->values(
#         name       => $data->{name},
#         email      => $data->{email},
#         role       => $data->{role} // 'user',
#         created_at => $now,
#         updated_at => $now,
#     );
    
#     $dbh->do($insert->sql($dbh), undef, $insert->bind_params());
#     my $id = $dbh->{mysql_insertid};
    
#     return {
#         id         => $id,
#         name       => $data->{name},
#         email      => $data->{email},
#         role       => $data->{role} // 'user',
#         created_at => $now,
#         updated_at => $now,
#     };
# }

# ------------------------
# Update user
# ------------------------
sub update_user {
    my ($id, $data) = @_;
    my $schema = RebirthAPI::DB::schema();
    my $users = $schema->table('users');

    my $now = DateTime->now->iso8601();

    my @update;
    push @update, $users->column('name') => $data->{name} if exists $data->{name};
    push @update, $users->column('email') => $data->{email} if exists $data->{email};
    push @update, $users->column('role') => $data->{role} if exists $data->{role};
    push @update, $users->column('updated_at') => $now;

    
    my $update_sql = Fey::SQL->new_update();
    $update_sql->update($users)
                ->set(@update)
                ->where($users->column('id'), '=', $id);

    my $dbh = RebirthAPI::DB::dbh();
    my $sth = $dbh->prepare($update_sql->sql($dbh));
    $sth->execute($update_sql->bind_params);

    return get_user($id);
}
# sub update_user {
#     my ($id, $data) = @_;
#     my $dbh = RebirthAPI::DB::dbh();

#     my $now = DateTime->now->iso8601();

#     # Build update fields dynamically
#     my @fields;
#     my @binds;

#     if (exists $data->{name}) {
#         push @fields, "name = ?";
#         push @binds,  $data->{name};
#     }
#     if (exists $data->{email}) {
#         push @fields, "email = ?";
#         push @binds,  $data->{email};
#     }
#     if (exists $data->{role}) {
#         push @fields, "role = ?";
#         push @binds,  $data->{role};
#     }

#     # Always update updated_at
#     push @fields, "updated_at = ?";
#     push @binds,  $now;

#     my $sql = "UPDATE users SET " . join(", ", @fields) . " WHERE id = ?";
#     push @binds, $id;

#     my $sth = $dbh->prepare($sql);
#     $sth->execute(@binds);

#     return get_user($id);
# }

# # ------------------------
# # Delete user
# # ------------------------
sub delete_user {
    my ($id) = @_;
    my $schema = RebirthAPI::DB::schema();
    my $users = $schema->table('users');

    my $delete_sql = Fey::SQL::Delete->new();
    $delete_sql->from($users)
                ->where($users->column('id'), '=', Fey::Literal->new_from_scalar($id));

    my $dbh = RebirthAPI::DB::dbh();
    my $sth = $dbh->prepare($delete_sql->sql($dbh));
    $sth->execute($delete_sql->bind_params);

    return $sth->rows; # 1 if deleted, 0 if not found 
}
# sub delete_user {
#     my ($id) = @_;

#     my $dbh = RebirthAPI::DB::dbh();
#     my $sth = $dbh->prepare("DELETE FROM users WHERE id = ?");
#     $sth->execute($id);

#     return $sth->rows;  # returns 1 if deleted, 0 if not found
# }

1;