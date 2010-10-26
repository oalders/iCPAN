#!/usr/bin/env perl

use Modern::Perl;
use Data::Dump qw( dump );
use Every;
use Find::Lib '../lib';

use iCPAN;
my $icpan = iCPAN->new;
my $rs  = $icpan->meta_index->schema->resultset( 'iCPAN::Meta::Schema::Result::Module' );

my $index = $icpan->pkg_index;
my $count = 0;

my @rows = ();
foreach my $key ( sort keys %{$index} ) {

    my %create = ( name => $key );
    foreach my $col ( 'archive', 'pauseid', 'version', 'dist', 'distvname' ) {
        $create{$col} = $index->{$key}->{$col};
    }

    push @rows, \%create;

}

$rs->delete;
$rs->populate( \@rows );