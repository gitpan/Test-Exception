#! /usr/bin/perl -w

BEGIN {

use strict;
use Test::Builder;
use File::Find;
use File::Spec;

my $Test = Test::Builder->new;


eval 'use Pod::Coverage';
$Test->skip_all("need Pod::Coverage") if $@;


my @Blib = grep /blib/, @INC;
$Test->skip_all("no blib directories in \@INC") unless @Blib;


my @Modules = ();
find( 
	sub {
		return unless $_ =~ m/\.pm$/;
		my $module = $File::Find::name;
		$module =~ s/\.pm$//s;
		$module =~ s/^\Q$File::Find::topdir\E//s;
		$module = join('::', grep !/^$/, File::Spec->splitdir($module));
		push @Modules, $module;
	}, @Blib
);
$Test->skip_all("no modules in (@Blib)") unless @Modules;


$Test->no_plan;
	
	
foreach my $module (sort @Modules) {
	my $pc = new Pod::Coverage package => $module;
	my $coverage = $pc->coverage;
	my $ok = defined($coverage) && ($coverage == 1);
	if (defined($coverage)) {
		$Test->ok(1, "$module->$_ documented") foreach sort $pc->covered;
		$Test->ok(0, "$module->$_ documented") foreach sort $pc->uncovered;
		$Test->diag("$module undocumented: ". join(', ', $pc->uncovered)) unless $ok;
	} else {
		$Test->ok(0, "$module unrated: ". $pc->why_unrated)
	};
};

};
