#! /usr/bin/perl -w

use strict;
use Carp;
use Test::Builder::Tester tests => 1;
use Test::More;

use Test::Exception;

test_out('not ok 1 - threw /fribble/');
test_fail(+1);
throws_ok {confess('died')} '/fribble/';
my $exception = $@;
test_diag('expecting: /fribble/');
test_diag(split /\n/, "found: $exception");
test_test('regex in stacktrace ignored');
