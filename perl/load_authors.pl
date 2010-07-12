#!/usr/bin/perl

use Modern::Perl;

use Data::Dump qw( dump );
use Find::Lib 'lib';
use iCPAN;
use IO::File;
use IO::Uncompress::AnyInflate qw(anyinflate $AnyInflateError);

my $minicpan = "$ENV{'HOME'}/minicpan" || shift @ARGV;
my $file = "$minicpan/authors/01mailrc.txt.gz";

my $z = new IO::Uncompress::AnyInflate $file
    or die "anyinflate failed: $AnyInflateError\n";

my $iCPAN  = iCPAN->new;
my $schema = $iCPAN->schema;

while ( my $line = $z->getline() ) {

    if ( $line =~ m{alias\s(\w*)\s{1,}"(.*)<(.*)>"}gxms ) {
        my $author = $schema->resultset( 'iCPAN::Schema::Result::Zauthor' )
            ->find_or_create( { zpauseid => $1, zname => $2, zemail => $3 } );
    }

}

