#!perl

use Modern::Perl;
use Data::Dump qw( dump );
use Find::Lib '../lib';
use iCPAN;
use Time::HiRes qw( gettimeofday tv_interval );

my $t_begin = [ gettimeofday ];

my $icpan = iCPAN->new;
$icpan->debug( $ENV{'DEBUG'} );

my @modules = @ARGV;

if ( scalar @modules == 0 ) {
    my $index = $icpan->pkg_index;
    @modules = sort keys %{$index};
}

my $attempts = 0;
my $schema = $icpan->schema;

MODULE:
foreach my $module_name ( @modules ) {

    my $t0 = [ gettimeofday];
    say "$module_name";# if $icpan->debug;
    $icpan->module_name( $module_name );
    my $module = $icpan->module;
    $module->process;

    my $iter_time = tv_interval( $t0, [gettimeofday] );
    my $elapsed = tv_interval( $t_begin, [gettimeofday] );
    
    #if ( $icpan->debug ) {
        ++$attempts;
        say "$iter_time to process module";
        say "$elapsed so far... ($attempts modules)";        
    #}
  
}

my $t_elapsed = tv_interval( $t_begin, [ gettimeofday ] );
say "Entire process took $t_elapsed";
