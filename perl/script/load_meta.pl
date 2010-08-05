#!/usr/bin/env perl

use Modern::Perl;
use Data::Dump qw( dump );
use Every;
use Find::Lib '../lib';

use iCPAN;
use iCPAN::Meta;

my $icpan = iCPAN->new;
my $meta  = iCPAN::Meta->new;

my $index = $icpan->pkg_index;
my $count = 0;

foreach my $key ( sort keys %{$index} ) {
    my $module
        = $meta->schema->resultset( 'iCPAN::Meta::Schema::Result::Module' )
        ->find_or_create( { name => $key } );

    foreach my $col ( 'archive', 'pauseid', 'version' ) {
        $module->$col( $index->{$key}->{$col} );
    }

    $module->update;
    say $key if every(100);
}
