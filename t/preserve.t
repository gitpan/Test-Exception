#! /usr/bin/perl -Tw

use strict;

use Test::More tests => 4;
use Test::Exception;

sub div {
   my ($a, $b) = @_;
   return( $a / $b );
};

dies_ok { div(1, 0) } 'exception thrown okay in dies_ok';
like( $@, '/^Illegal division by zero/', 'exception preserved' );

throws_ok { div(1, 0) } '/^Illegal division by zero/', 'exception thrown okay in throws_ok';
like( $@, '/^Illegal division by zero/', 'exception preserved' );
