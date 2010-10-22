package iCPAN::Dist;

use Archive::Tar;
use Moose;
use Modern::Perl;
use Data::Dump qw( dump );

with 'iCPAN::Role::Common';

has 'author' => (
    is         => 'ro',
    isa        => 'iCPAN::Schema::Result::Zauthor',
    lazy_build => 1,
);

has 'content' => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);

has 'name' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'archive' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'file' => ( is => 'rw', );

has 'metadata' => ( is => 'rw', isa => 'iCPAN::Meta::Schema::Result::Module' );

has 'pauseid' => (
    is         => 'ro',
    required   => 1,
    lazy_build => 1,
);

has 'pm_name' => (
    is         => 'rw',
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

sub _build_author {

    my $self = shift;

    die "no pauseid" if !$self->pauseid;
    my $author = $self->schema->resultset( 'iCPAN::Schema::Result::Zauthor' )
        ->find_or_create( { zpauseid => $self->pauseid } );
    return $author;

}

sub _build_path {
    my $self = shift;
    return $self->meta->archive;
}

sub archive_path {

    my $self = shift;
    return $self->minicpan . "/authors/id/" . $self->meta->archive;

}

sub process {

    my $self        = shift;
    my $module_name = $self->name;
    my $debug       = $self->debug;

    if ( !$self->author ) {
        say
            "skipping $module_name. cannot find $self->pauseid in author table";
        return;
    }

    #my $iter = Archive::Tar->iter( $self->archive_path, 1,
    #    { filter => qr/\.(pm|pod)$/ } );

    my @files = @{ $self->files };

FILE:

    # locate the file we care about in the archive
    foreach my $file ( @files ) {

        #while ( my $f = $iter->() ) {

        #my $file = $f->name;
        print "checking: $file " if $debug;

        next FILE if !$self->file_ok( $file );

        say "found : $file ";
        $self->file( $file );

        $self->parse_pod( $file );

        $self->tar->clear;
        return;
    }

    $self->tar->clear if $self->tar;
    warn $self->name . " no success!!!!!!!!!!!!!!!!" if $self->debug;

    return;

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

sub _build_pm_name {
    my $self = shift;
    return $self->_module_root . '.pm';
}

sub _build_pod_name {
    my $self = shift;
    return $self->_module_root . '.pod';
}

sub _build_tar {

    my $self = shift;
    say "archive path: " . $self->archive_path if $self->debug;
    return Archive::Tar->new( $self->archive_path );

}

sub _module_root {
    my $self = shift;
    my @module_parts = split( "::", $self->name );
    return pop( @module_parts );
}

1;
