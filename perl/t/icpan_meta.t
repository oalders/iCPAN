#!/usr/bin/perl

use Data::Dump qw( dump );
use Modern::Perl;
use Test::More qw( no_plan );

require_ok('iCPAN::Meta');

my $meta = iCPAN::Meta->new;

isa_ok( $meta, 'iCPAN::Meta');
ok( $meta->dbh, "got dbh");
isa_ok( $meta->dbh, 'DBI::db');


ok( -e $meta->db_file, 'database exists at: ' . $meta->db_file );
ok( $meta->dsn, "got dsn: " . $meta->dsn );
