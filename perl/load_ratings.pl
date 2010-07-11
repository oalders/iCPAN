#!/usr/bin/perl

=head2 SYNOPSIS

This script updates the database with CPAN ratings.  You'll need to have updated
the modules table before running this.  The csv file can be downloaded from:

http://cpanratings.perl.org/csv/all_ratings.csv

=cut

use Data::Dump qw( dump );
use Find::Lib 'lib';
use iCPAN;
use Modern::Perl;
use Parse::CSV;

#use Parse::CPAN::Ratings;
#my $ratings = Parse::CPAN::Ratings->new( filename => 'all_ratings.csv' );

my $iCPAN  = iCPAN->new;
my $schema = $iCPAN->schema;

my $parser = Parse::CSV->new(
    file   => 'all_ratings.csv',
    fields => 'auto',
);

while ( my $rating = $parser->fetch ) {
    
    say dump $rating;
    my $distro = $rating->{distribution};
    $distro =~ s{-}{::}g;
    #say $distro;

    my $module = $schema->resultset( 'iCPAN::Schema::Zmodule' )
        ->find( { zname => $distro } );
        
    if ( !$module ) {
        say "cannot find $distro";
        next;
    }
    
    $module->zrating( $rating->{rating} );
    $module->zreview_count( $rating->{review_count} );
    $module->update;
    
}
