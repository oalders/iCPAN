#!/usr/bin/perl

use Modern::Perl;
use Test::More tests => 5;

require_ok('iCPAN');
my $icpan = iCPAN->new;

isa_ok( $icpan, 'iCPAN');
ok( $icpan->dbh, "got dbh");
isa_ok( $icpan->dbh, 'DBI::db');

ok( $icpan->dsn, "got dsn: " . $icpan->dsn );
