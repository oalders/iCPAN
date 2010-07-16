#!/usr/bin/perl

=head2 SYNOPSIS

This script will trim the module table down to X entries.  Use this *only*
when you are testing deployment and need to increase the speed of your
"build and run".  You may want to make a backup of your db before running
this script.

perl trim_db.pl 1000

Will remove every module entry with an id greater than 1,000

=cut

use Data::Dump qw( dump );
use Find::Lib '../lib';
use iCPAN;
use Modern::Perl;

my $iCPAN = iCPAN->new;
my $dbh   = $iCPAN->dbh;

my $last_id = shift @ARGV;
if ( !$last_id ) {
    die "Usage: perl trim_db.pl last_id";
}

$dbh->do( "DELETE FROM ZMODULE WHERE Z_PK > $last_id" );
my $vacuum = $dbh->do( "VACUUM" );

my $count = $iCPAN->schema->resultset( 'iCPAN::Schema::Result::Zmodule' )
    ->search( {} )->count;
    
say "$count rows remaining in module table";
