#! /usr/bin/perl -Tw

use strict;

use Test::Builder::Tester tests => 15;

BEGIN { 
	my $module = 'Test::Exception';
    eval "use $module";
	if ($@) {
		print "Bail out!: Cannot find $module in (@INC)\n";
		exit(255);
	};
};


{
	package Local::Error::Simple;
	sub new { return bless {}, shift };
};


{	
	package Local::Error::Test;
	use base qw(Local::Error::Simple);
};


{	
	package Local::Error::Overload;
	use base qw(Local::Error::Simple);
	use overload q{""} => sub { "overloaded" }, fallback => 1;
};

my $SIMPLE = Local::Error::Simple->new();
my $TEST = Local::Error::Test->new();
my $OVERLOAD = Local::Error::Overload->new();

sub error {
	my $type = shift;
	if ($type eq "simple") {
		die $SIMPLE;
	} elsif ($type eq "test") {
		die $TEST;
	} elsif ($type eq "overload") {
		die $OVERLOAD;
	} elsif ($type eq "die") {
		die "a normal die\n";
	} else {
		1;
	};
};


test_out("ok 1");
dies_ok { error("die") };
test_test("dies_ok: die");

test_out("not ok 1 - lived. oops");
test_fail(+1);
dies_ok { error("none") } "lived. oops";
test_test("dies_ok: normal exit detected");

test_out("ok 1 - lived");
lives_ok { 1 } "lived";
test_test("lives_ok: normal exit");

test_out("not ok 1");
test_fail(+2);
test_diag("died: a normal die");
lives_ok { error("die") };
test_test("lives_ok: die detected");

test_out("not ok 1");
test_fail(+2);
test_diag("died: Local::Error::Overload (overloaded)");
lives_ok { error("overload") };
test_test("lives_ok: die detected");

test_out("ok 1 - expecting normal die");
throws_ok { error("die") } '/normal/', 'expecting normal die';
test_test("throws_ok: regex match");

test_out("not ok 1");
test_fail(+3);
test_diag("expecting: /abnormal/ exception");
test_diag("found: a normal die");
throws_ok { error("die") } '/abnormal/';
test_test("throws_ok: regex bad match detected");

test_out("ok 1");
throws_ok { error("simple") } "Local::Error::Simple";
test_test("throws_ok: identical exception class");

test_out("not ok 1");
test_fail(+3);
test_diag("expecting: Local::Error::Simple exception");
test_diag("found: normal exit");
throws_ok { error("none") } "Local::Error::Simple";
test_test("throws_ok: exception on normal exit");

test_out("ok 1");
throws_ok { error("test") } "Local::Error::Simple";
test_test("throws_ok: exception sub-class");

test_out("not ok 1");
test_fail(+3);
test_diag("expecting: Local::Error::Test exception");
test_diag("found: $SIMPLE");
throws_ok { error("simple") } "Local::Error::Test";
test_test("throws_ok: bad sub-class match detected");

test_out("not ok 1");
test_fail(+3);
test_diag("expecting: Local::Error::Test exception");
test_diag("found: Local::Error::Overload (overloaded)");
throws_ok { error("overload") } "Local::Error::Test";
test_test("throws_ok: throws_ok found overloaded exception");

test_out("not ok 1");
test_fail(+3);
test_diag("expecting: Local::Error::Overload (overloaded) exception");
test_diag("found: $TEST");
throws_ok { error("test") } $OVERLOAD;
test_test("throws_ok: throws_ok found overloaded exception");

test_out("ok 1");
my $e = Local::Error::Test->new("hello");
throws_ok { error("test") } $e;
test_test("throws_ok: class from object match");

test_out("ok 1");
throws_ok { error("none") } qr/^$/;
test_test("throws_ok: normal exit matched");
