#! /usr/bin/perl -w

BEGIN {

	use strict;
	use Test::Builder;
	use File::Find;
	
	my $Test = Test::Builder->new;
	
	eval 'use Pod::Checker';
	$Test->skip_all("need Pod::Checker") if $@;
	
	eval 'use IO::String';
	$Test->skip_all("need IO::String") if $@;
	
	my @Blib = grep /blib/, @INC;
	$Test->skip_all("no blib directories in \@INC") unless @Blib;
	
	my @Modules = ();
	find(sub {(push @Modules, $File::Find::name) if $_ =~ m/\.pm$/}, @Blib);
	$Test->skip_all("no modules in (@Blib)") unless @Modules;
	
	$Test->expected_tests(scalar(@Modules));
	
	foreach my $module (sort @Modules) {
		my $errors = IO::String->new;
		my $checker = Pod::Checker->new(-warnings => 1);
		$checker->parse_from_file($module, $errors);
		$errors = ${$errors->string_ref};
		my $ok = $checker->num_errors < 1 && $errors !~ m/WARNING/;
		$Test->ok($ok, "$module POD legal") || $Test->diag($errors);
	};

};
