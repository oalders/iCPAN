#!/usr/bin/perl

=head1 SYNOPSIS

Loads author info into db.  Requires the presence of a local minicpan.

    perl script/load_authors.pl /path/to/minicpan

=cut

use Modern::Perl;

use Data::Dump qw( dump );
use Every;
use Find::Lib '../lib';
use iCPAN;
use IO::File;
use IO::Uncompress::AnyInflate qw(anyinflate $AnyInflateError);

my $minicpan = "$ENV{'HOME'}/minicpan" || shift @ARGV;

if ( !-d $minicpan ) {
    die "Usage: perl script/load_authors.pl /path/to/minicpan";
}

my $file = "$minicpan/authors/01mailrc.txt.gz";

my $z = new IO::Uncompress::AnyInflate $file
    or die "anyinflate failed: $AnyInflateError\n";

my $icpan = iCPAN->new;
my $rs    = $icpan->schema->resultset( 'iCPAN::Schema::Result::Zauthor' );
$rs->delete;

my @authors = ();

while ( my $line = $z->getline() ) {

    if ( $line =~ m{alias\s([\w\-]*)\s{1,}"(.*)<(.*)>"}gxms ) {

        push @authors,
            {
            zpauseid => $1,
            zname    => $2,
            zemail   => $3
            }

    }

}

$rs->populate( \@authors );
