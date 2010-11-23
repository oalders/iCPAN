#!/usr/bin/env perl

use Modern::Perl;
use Data::Dump qw( dump );
use Every;
use Find::Lib '../lib';
use iCPAN;
use Time::HiRes qw( gettimeofday tv_interval );

my $t_begin = [gettimeofday];

my $attempts = 0;
my $every    = 20;
my $icpan    = iCPAN->new;
my $meta     = $icpan->meta_index;
$icpan->debug( $ENV{'DEBUG'} );

my @dists = @ARGV;
@ARGV = ();

my $total_dists = 1;

# need to reset @ARGV in order to avoid this nasty error in Perl::Tidy
# "You may not specify any filenames when a source array is given"

if ( scalar @dists ) {
    foreach my $dist_name ( @dists ) {
        process_dist( $dist_name );
    }
}

else {
    my $schema = $meta->schema;
    my $constraints = { name => { like => 'a%' } };
    $constraints = {};
    
    my $search
        = $meta->schema->resultset( 'iCPAN::Meta::Schema::Result::Module' )
        ->search( $constraints,
        { columns => ['dist'], distinct => 1, order_by => 'dist ASC' } );

    $total_dists = $search->count;

    while ( my $row = $search->next ) {
        process_dist( $row->dist );
    }

}

my $t_elapsed = tv_interval( $t_begin, [gettimeofday] );
say "Entire process took $t_elapsed";

sub process_dist {

    my $dist_name = shift;
    my $t0        = [gettimeofday];

    say '+' x 20 . " DIST: $dist_name" if $icpan->debug;

    my $dist = $icpan->dist( $dist_name );
    $dist->meta_index( $meta );
    $dist->process;

    my $iter_time = tv_interval( $t0,      [gettimeofday] );
    my $elapsed   = tv_interval( $t_begin, [gettimeofday] );

    ++$attempts;
    if ( every( $every ) ) {

        say '#' x 78;
        say "$dist_name";    # if $icpan->debug;
        say "$iter_time to process dist";
        say "$elapsed so far... ($attempts dists out of $total_dists)";

        my $seconds_per_dist = $elapsed / $attempts;
        say "average $seconds_per_dist per dist";

        my $total_duration = $seconds_per_dist * $total_dists;
        my $total_hours    = $total_duration / 3600;
        say "estimated total time: $total_duration ($total_hours hours)";
        say '#' x 78;

    }

    $dist->tar->clear if $dist->tar;
    $dist = undef;
    return;

}
