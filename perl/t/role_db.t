#!/usr/bin/perl

use Data::Dump qw( dump );
use Modern::Perl;
use Test::More tests => 7;

require_ok('iCPAN');
my $icpan = iCPAN->new;

isa_ok( $icpan, 'iCPAN');
ok( $icpan->dbh, "got dbh");
isa_ok( $icpan->dbh, 'DBI::db');

ok( $icpan->dsn, "got dsn: " . $icpan->dsn );

cmp_ok( $icpan->db_path, 'eq', '../../iCPAN.sqlite', 'correct default db path' );

my $icpan2 = iCPAN->new;
$icpan->db_path('../iCPAN.sqlite');
cmp_ok( $icpan->db_path, 'eq', '../iCPAN.sqlite',  'correct custom db path');