#!/usr/bin/env perl

use Modern::Perl;
use Data::Dump qw( dump );
use Find::Lib '../lib';
use iCPAN;
use iCPAN::Meta;
use Time::HiRes qw( gettimeofday tv_interval );

my $t_begin = [gettimeofday];

my $icpan = iCPAN->new;
my $meta  = iCPAN::Meta->new;
$icpan->debug( $ENV{'DEBUG'} );

my @modules = @ARGV;

if ( scalar @modules ) {
    foreach my $module_name ( @modules ) {
        process_module( $module_name );
    }
}
else {
    my $schema = $meta->schema;
    my $search
        = $meta->schema->resultset('iCPAN::Meta::Schema::Result::Module')
        ->search( {}, { order_by => 'id asc' } );
        
    while ( my $row = $search->next ) {
        my $module = process_module( $row->name );
        $row->file( $module->file );
        $row->update;
    }
}

my $attempts = 0;
my $schema   = $icpan->schema;

MODULE:
foreach my $module_name ( @modules ) {

}

my $t_elapsed = tv_interval( $t_begin, [gettimeofday] );
say "Entire process took $t_elapsed";

sub process_module {

    my $module_name = shift;
    my $t0          = [gettimeofday];
    say "$module_name";    # if $icpan->debug;
    $icpan->module_name( $module_name );
    my $module = $icpan->module;
    $module->process;

    my $iter_time = tv_interval( $t0,      [gettimeofday] );
    my $elapsed   = tv_interval( $t_begin, [gettimeofday] );

    ++$attempts;
    say "$iter_time to process module";
    say "$elapsed so far... ($attempts modules)";
    
    return $module;

}
