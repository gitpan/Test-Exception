#!/usr/bin/perl -Tw

# Make sure caller() is undisturbed.

use strict;
use Test::More tests => 2;

use Test::Exception;

eval { die caller() . "\n" };
is( $@, "main\n" );

throws_ok { die caller() . "\n" }  qr/^main$/;
