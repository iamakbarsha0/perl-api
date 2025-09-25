package RebirthAPI::DB;
use strict;
use warnings;
use MongoDB;
use YAML::Tiny;

my $config;
my $client;
my $db;

# Load config only once
sub _config {
    return $config if $config;
    $config = YAML::Tiny->read('config.yml')->[0] || {};
    return $config;
}

# MongoDB client singleton
sub client {
    return $client if $client;
    my $mongo_cfg = _config()->{plugins}->{MongoDB} || {};
    my $uri = $mongo_cfg->{mongo_uri} or die "\n Missing mongo_uri in config.yml file \n";
    print "\n[DB] Connecting to MongoDB URI: $uri\n";
    $client = MongoDB->connect($uri);
    return $client;
}

# MongoDB client singleton
sub db {
    return $db if $db;
    my $mongo_cfg = _config()->{plugins}->{MongoDB} || {};
    my $db_name = $mongo_cfg->{mongo_db_name} or die "\n Missing db name in config.yml file \n";
    print "[DB] Using database: $db_name\n";
    $db = client()->get_database($db_name);
    return $db;
}

# Get a collection handle
sub collection {
    my ($name) = @_;
    die "\n collection() requires a name \n" unless $name;
    return db()->get_collection($name);
}

1;
