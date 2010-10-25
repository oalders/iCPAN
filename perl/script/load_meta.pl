#!/usr/bin/env perl

use Modern::Perl;
use Data::Dump qw( dump );
use Every;
use Find::Lib '../lib';

use iCPAN;
my $icpan = iCPAN->new;
my $meta  = $icpan->meta_index;

my $index = $icpan->pkg_index;
my $count = 0;

foreach my $key ( sort keys %{$index} ) {
    my $module
        = $meta->schema->resultset( 'iCPAN::Meta::Schema::Result::Module' )
        ->find_or_create( { name => $key } );

    foreach my $col ( 'archive', 'pauseid', 'version', 'dist', 'distvname' ) {
        $module->$col( $index->{$key}->{$col} );
    }

    $module->update;
    say $key if every(100);
}
