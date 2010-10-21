#!/usr/bin/perl

use Data::Dump qw( dump );
use Modern::Perl;
use Test::More tests => 10;

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

my $file = $icpan->open_pkg_index;
isa_ok( $file, 'IO::File');

my $index = $icpan->pkg_index;
my $modules = keys %{ $index };
cmp_ok( $modules , '>', '75000', "have $modules modules in index");

$icpan->module_name('HTTP::BrowserDetect');
my $module = $icpan->module;
isa_ok( $module, 'iCPAN::Module');
