#!/usr/bin/env perl

use Modern::Perl;
use Data::Printer;
use Test::More;

use iCPAN;

my $icpan  = iCPAN->new;
my $schema = $icpan->schema;

my $pod_rs = $icpan->schema->resultset('Zmodule')
    ->search( { 'Pod.ZHTML' => undef }, { prefetch => 'Pod' } );
ok( !$pod_rs->count, "no modules with missing Pod" );

diag $pod_rs->count;

done_testing();
