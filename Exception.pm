#! /usr/bin/perl -w

package Test::Exception;
use 5.005;
use strict;
use Test::Builder;
use base qw(Exporter);

use vars qw($VERSION @EXPORT);
$VERSION = '0.09';
@EXPORT = qw(dies_ok lives_ok throws_ok);

my $Tester = Test::Builder->new;


=head1 NAME

Test::Exception - Convenience routines for testing exception based code

=head1 SYNOPSIS

  use Test::More tests => 4;
  use Test::Exception;

  # Check that something died
  dies_ok {$foo->method1} 'expecting to die';

  # Check that something did not die
  lives_ok {$foo->method2} 'expecting to live';

  # Check that the stringified exception matches given regex
  throws_ok {$foo->method3} qr/division by zero/, 'zero caught okay';

  # Check an exception of the given class (or subclass) is thrown
  throws_ok {$foo->method4} 'Error::Simple', 'simple error thrown';


=head1 DESCRIPTION

This module provides a few convenience methods for testing exception based 
code. It is built with L<Test::Builder> and plays happily with L<Test::More> and friends.

If you are not already familiar with L<Test::More> now would be the time to go take a look.


=over 4

=item dies_ok BLOCK TEST_NAME

Tests to see that BLOCK exits by dying, rather than by exiting normally. For example:

    sub div {
        my ($a, $b) = @_;
        return( $a / $b );
    };

    dies_ok { div(1, 0) } 'divide by zero detected';

A true value is returned if the test succeeds, false otherwise. $@ is guaranteed to be the cause of death (if any).

The test name is optional, but recommended. 


=cut

sub dies_ok (&@) {
	my ($sub, $message) = @_;
	eval {&$sub};
	my $exception = $@;
	my $ok = $Tester->ok(!(defined($@) && $@ eq ''), $message);
	$@ = $exception;
	return($ok);
}


=item lives_ok BLOCK TEST_NAME

Tests to see that BLOCK exits normally, and doesn't die. For example:

    sub read_file {
        my $file = shift;
        local $/ = undef;
        open(FILE, $file) or die "open failed ($!)\n";
        $file = <FILE>;
        close(FILE);
        return($file);
    };

    my $file;
    lives_ok { $file = read_file('test.txt') } 'file read';

Should a C<lives_ok> test fail it produces appropriate diagnostic messages. For example:

    not ok 1 - file read
    #     Failed test (test.t at line 15)
    # died: open failed (No such file or directory)

A true value is returned if the test succeeds, false otherwise. $@ is guaranteed to be the cause of death (if any).

The test name is optional, but recommended. 

=cut

sub lives_ok (&@) {
	my ($sub, $message) = @_;
	eval {&$sub};
	my $exception = $@;
	my $lived = defined($@) && $@ eq '';
	my $ok = $Tester->ok($lived, $message);
	$Tester->diag("died: $@") unless $lived;
	$@ = $exception;
	return($ok);
}


=item throws_ok BLOCK REGEX, TEST_NAME

=item throws_ok BLOCK CLASS, TEST_NAME

Tests to see that BLOCK throws a specific exception. 

In the first form the test passes if the stringified exception matches the give regular expression. For example:

    throws_ok { 
        read_file('test.txt') 
    } qr/No such file/, 'no file';

If your perl does not support C<qr//> you can also pass a regex-like string, for example:

    throws_ok { 
        read_file('/etc/kcpassword') 
    } '/Permission denied/', 'no permissions';

I<NOTE:> Any line in the exception containing the string C<Test::Exception::throws_ok(> is ignored by the regex. Otherwise tests on exceptions that includes a stacktrace can match because the regex appears in the stacktrace as an argument to throws_ok.

The second form of throws_ok test passes if the exception is of the same class as the one supplied, or a subclass of that class. For example:

    throws_ok {$foo->bar} "Error::Simple", 'simple error';

Will only pass if the C<bar> method throws an Error::Simple exception, or a subclass of an Error::Simple exception.

You can get the same effect by passing an instance of the exception you want to look for. The following is equivalent to the previous example:

    my $SIMPLE = Error::Simple->new();
    throws_ok {$foo->bar} $SIMPLE, 'simple error';

Should a C<throws_ok> test fail it produces appropriate diagnostic messages. For example:

    not ok 3 - simple error
    #     Failed test (test.t at line 48)
    # expecting: Error::Simple exception
    # found: normal exit

A true value is returned if the test succeeds, false otherwise. $@ is guaranteed to be the cause of death (if any).

The test name is optional, but recommended. 

=cut

sub throws_ok (&@) {
	my ($sub, $class, $message) = @_;
	eval {&$sub()};
	my $exception = $@;
	my $ok;
	unless (defined($exception) && $exception eq '') {
		my $regex;
		if ($regex = $Tester->maybe_regex($class)) {
			my $string = $exception;
			$string =~ s/^.*\QTest::Exception::throws_ok(\E.*$//mg;
			$ok = ($string =~ m/$regex/);
		} elsif (ref($exception)) {
			$class = ref($class) if ref($class);
			$ok = UNIVERSAL::isa($exception, $class);
		};
	};
	$Tester->ok($ok, $message);
	unless ($ok) {
		$exception = 'normal exit' if $exception eq '';
		$class = 'undef' unless defined($class);
		$class .= " exception" unless ref($class);
		$Tester->diag("expecting: $class");
		$Tester->diag("found: $exception");
	};
	$@ = $exception;
	return($ok);
};

=back


=head1 BUGS

None known at the time of writing. 

If you find any please let me know by e-mail, or report the problem with <http://rt.cpan.org/>.


=head1 TO DO

Nothing at the time of writing.

If you think this module should do something that it doesn't do at the moment please let me know.


=head1 SEE ALSO


L<Test::Builder> provides a consistent backend for building test libraries. The following modules are all built with L<Test::Builder> and work well together.

=over 4

=item L<Test::Simple> & L<Test::More>

Basic utilities for writing tests.

=item L<Test::Differences>

Test strings and data structures and show differences if not ok.

=item L<Test::Inline>

Inlining your tests next to the code being tested.

=back


=head1 AUTHOR

Adrian Howard <adrianh@quietstars.com>

If you can spare the time, please drop me a line if you find this module useful.


=head1 ACKNOWLEGEMENTS

Thanks to Michael G Schwern and Mark Fowler for suggestions and comments on initial versions of this module.

This module wouldn't be possible without the excellent Test::Builder. Thanks to chromatic <chromatic@wgz.org> and Michael G Schwern <schwern@pobox.com> for creating such a useful module.


=head1 LICENCE

Copyright 2002 Adrian Howard, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

=cut

1;
