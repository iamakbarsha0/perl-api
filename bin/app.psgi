#!/usr/bin/env perl

use strict;
use warnings;
use FindBin;
use lib "$FindBin::Bin/../lib";

use RebirthAPI::App;

RebirthAPI::App->to_app;