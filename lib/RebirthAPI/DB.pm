package RebirthAPI::DB;
use strict;
use warnings;

use DBI;
use Fey;
use Fey::Schema;
use Fey::Table;
use Fey::ORM::Schema;

use YAML::Tiny;

my $dbh;
my $schema;

sub dbh {
    return $dbh if $dbh;
    my $config = YAML::Tiny->read('config.yml')->[0];
    my $dsn = $config->{plugins}->{SQL}->{dsn}; # "dbi:mysql:database=rebirth;host=localhost"
    my $user = $config->{plugins}->{SQL}->{user}; # root
    my $pass = $config->{plugins}->{SQL}->{pass}; # root

    warn "user -> $user\n";
    warn "pass -> $pass\n";

    $dbh = DBI->connect(
        $dsn, $user, $pass,
        {
            RaiseError => 1,
            AutoCommit => 1,
            mysql_enable_utf8mb4 => 1,
        }
    );
    # $dbh = DBI->connect($dsn, $user, $pass, 
    # { RaiseError => 1, AutoCommit => 1 });
    warn "MYSQL - DB connected\n" if $dbh;
    return $dbh;
}

sub schema {
    return $schema if $schema;
    $schema = Fey::Schema->new( name => 'rebirth' );

    my $users = Fey::Table->new( name => 'users', schema => $schema );

    my $col_id = Fey::Column->new(
        name        => 'id',
        type        => 'integer',
        is_nullable => 0,
    );

    my $col_name = Fey::Column->new(
        name => 'name',
        type => 'varchar',
    );

    my $col_email = Fey::Column->new(
        name => 'email',
        type => 'varchar',
    );

    my $col_role = Fey::Column->new(
        name => 'role',
        type => 'varchar',
    );

    my $col_created = Fey::Column->new(
        name => 'created_at',
        type => 'datetime',
    );

    my $col_updated = Fey::Column->new(
        name => 'updated_at',
        type => 'datetime',
    );

    # Add all columns to the table
    $users->add_column($col_id);
    $users->add_column($col_name);
    $users->add_column($col_email);
    $users->add_column($col_role);
    $users->add_column($col_created);
    $users->add_column($col_updated);

    # Set primary key explicitly
    # $users->set_primary_key($col_id);
    $users->add_candidate_key( $users->column('id') );

    $schema->add_table($users);
    return $schema;
}


1;