#!/usr/bin/env perl

use Modern::Perl;
use Data::Dump qw( dump );
use Every;
use Find::Lib '../lib';
use iCPAN;
use iCPAN::Meta;
use Time::HiRes qw( gettimeofday tv_interval );

my $t_begin = [gettimeofday];

my $attempts = 0;
my $every    = 20;
my $icpan    = iCPAN->new;
my $meta     = iCPAN::Meta->new;
$icpan->debug( $ENV{'DEBUG'} );

my @modules = @ARGV;
@ARGV = ();

# need to reset @ARGV in order to avoid this nasty error in Perl::Tidy
# "You may not specify any filenames when a source array is given"

if ( scalar @modules ) {
    foreach my $module_name ( @modules ) {
        process_module( $module_name );
    }
}

# if files aren't yet stored in the meta database, comment out that search
# constraint
else {
    my $schema      = $meta->schema;
    my $constraints = {};
    #$constraints = { file => { '!=' => undef } };

    my $search
        = $meta->schema->resultset( 'iCPAN::Meta::Schema::Result::Module' )
        ->search( $constraints, { order_by => 'id asc' } );

    while ( my $row = $search->next ) {
        my $module = process_module( $row->name );
        $row->file( $module->file );
        $row->update;
    }
}

my $t_elapsed = tv_interval( $t_begin, [gettimeofday] );
say "Entire process took $t_elapsed";

sub process_module {

    my $module_name = shift;
    my $t0          = [gettimeofday];
    $icpan->module_name( $module_name );
    my $module = $icpan->module;
    $module->process;

    my $iter_time = tv_interval( $t0,      [gettimeofday] );
    my $elapsed   = tv_interval( $t_begin, [gettimeofday] );

    ++$attempts;
    if ( every( $every ) ) {
        say "$module_name";    # if $icpan->debug;
        say "$iter_time to process module";
        say "$elapsed so far... ($attempts modules)";
    }

    return $module;

}
