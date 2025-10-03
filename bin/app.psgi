#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

$| = 1;   # autoflush STDOUT
use IO::Handle;
STDERR->autoflush(1);   # autoflush STDERR as well (important for warn)

use RebirthAPI::App;

RebirthAPI::App->to_app;