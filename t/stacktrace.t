#! /usr/bin/perl -w

use strict;
use Carp;
use Test::Builder::Tester tests => 2;
use Test::More;

BEGIN { 
	use_ok('Test::Exception')
		or Test::More->builder->BAILOUT('cannot load Test::Exception')
};

test_out('not ok 1');
test_fail(+1);
throws_ok {confess('died')} '/fribble/';
my $exception = $@;
test_diag('expecting: /fribble/ exception');
test_diag(split /\n/, "found: $exception");
test_test('regex in stacktrace ignored');
