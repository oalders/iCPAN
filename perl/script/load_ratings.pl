#!/usr/bin/perl

=head2 SYNOPSIS

Loads module ratings into module table.  Requires the following file
in the /perl directory:

http://cpanratings.perl.org/csv/all_ratings.csv

=cut

use Data::Dump qw( dump );
use Find::Lib '../lib';
use iCPAN;
use Modern::Perl;
use Parse::CSV;
use Path::Class::File;
use WWW::Mechanize;
use WWW::Mechanize::Cached;

my $filename = '/tmp/all_ratings.csv';
my $file = Path::Class::File->new( $filename );
my $mech = WWW::Mechanize::Cached->new;
#my $mech = WWW::Mechanize->new;

$mech->get( 'http://cpanratings.perl.org/csv/all_ratings.csv' );
my $fh = $file->openw();
print $fh $mech->content;

#use Parse::CPAN::Ratings;
#my $ratings = Parse::CPAN::Ratings->new( filename => $filename );

my $iCPAN  = iCPAN->new;
my $schema = $iCPAN->schema;

my $parser = Parse::CSV->new(
    file   => $filename,
    fields => 'auto',
);

while ( my $rating = $parser->fetch ) {

    #say dump $rating;
    my $distro = $rating->{distribution};
    $distro =~ s{-}{::}g;
    #say $distro;

    my $module = $schema->resultset( 'iCPAN::Schema::Result::Zmodule' )
        ->find( { zname => $distro } );

    if ( !$module ) {
        say "----> cannot find $distro";
        next;
    }
    else {
        say "$distro";
    }

    $module->zrating( $rating->{rating} );
    $module->zreview_count( $rating->{review_count} );
    $module->update;

}

unlink $filename;
