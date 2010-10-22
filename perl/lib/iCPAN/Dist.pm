package iCPAN::Dist;

use Archive::Tar;
use Moose;
use Modern::Perl;
use Data::Dump qw( dump );
use Devel::SimpleTrace;

use iCPAN::MetaIndex;
use iCPAN::Module;

with 'iCPAN::Role::Author';
with 'iCPAN::Role::Common';
with 'iCPAN::Role::DB';

has 'name' => (
    is         => 'rw',
    lazy_build => 1,
);

has 'archive' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'file' => ( is => 'rw', );

has 'metadata' => (
    is         => 'rw',
    isa        => 'iCPAN::Meta::Schema::Result::Module',
    lazy_build => 1
);

has 'module' => ( is => 'rw', isa => 'iCPAN::Module' );

has 'pauseid' => (
    is         => 'ro',
    required   => 1,
    lazy_build => 1,
);

has 'version' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'files' => (
    is         => 'ro',
    isa        => "ArrayRef",
    lazy_build => 1,
);

has 'tar' => (
    is         => 'rw',
    lazy_build => 1,
);



sub _build_path {
    my $self = shift;
    return $self->meta->archive;
}

sub archive_path {

    my $self = shift;
    return $self->minicpan . "/authors/id/" . $self->metadata->archive;

}

sub process {

    my $self    = shift;
    my $success = 0;
    my $module_rs = $self->modules;
    while ( my $found = $module_rs->next ) {

        say "checking " . $found->name if $self->debug;

        $self->module(
            iCPAN::Module->new( metadata => $found, tar => $self->tar, schema => $self->schema ) );

    FILE:
        foreach my $file ( @{ $self->files } ) {
            print "checking: $file " if $self->debug;
            next FILE if !$self->module->process( $file );

            say "found : $file ";
            ++$success;
            last FILE;
        }

    }

    if ( !$success && $self->debug ) {
        warn $self->name . " no success" . "!" x 20;
    }

    $self->tar->clear if $self->tar;
    return;

}

sub modules {

    my $self = shift;
    my $name = $self->name;
    $name =~ s{::}{-}g;
    $self->name( $name );

    return $self->meta_index->schema->resultset(
        'iCPAN::Meta::Schema::Result::Module' )
        ->search( { dist => $self->name } );

}

sub _build_files {

    my $self = shift;
    my $tar  = $self->tar;

    eval { $tar->read( $self->archive_path ) };
    if ( $@ ) {
        warn $@;
        return [];
    }

    my @files = $tar->list_files;
    return \@files;

}

sub _build_metadata {

    my $self = shift;
    my $metadata
        = $self->meta_index->schema->resultset(
        'iCPAN::Meta::Schema::Result::Module' )
        ->search( { dist => $self->name } )->first;

    return $metadata;

}

sub _build_tar {

    my $self = shift;
    say "archive path: " . $self->archive_path if $self->debug;
    return Archive::Tar->new( $self->archive_path );

}

1;
