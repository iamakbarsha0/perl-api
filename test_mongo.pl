#!/usr/bin/env perl
use strict;
use warnings;
use MongoDB;

my $client = MongoDB->connect('mongodb://localhost:27017');
my $db = $client->get_database('rebirth');
my $collection = $db->get_collection('users');

print $collection->count_documents({}), "\n";
