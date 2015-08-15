#!/usr/bin/env perl

use Modern::Perl;
use Test::More;

use iCPAN;

new_ok('iCPAN');

my $icpan = iCPAN->new;
ok( $icpan->dsn,    'dsn' );
ok( $icpan->schema, 'schema' );

done_testing();
