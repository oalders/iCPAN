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

has 'file' => ( is => 'rw', );

has 'metadata' => (
    is         => 'rw',
    isa        => 'iCPAN::Meta::Schema::Result::Module',
    lazy_build => 1
);

has 'module' => ( is => 'rw', isa => 'iCPAN::Module' );

has 'files' => (
    is         => 'ro',
    isa        => "HashRef",
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

=head2 archive_path

Full file path to module archive.

=cut

sub archive_path {

    my $self = shift;
    return $self->minicpan . "/authors/id/" . $self->metadata->archive;

}

=head2 process

Do the heavy lifting here.  First take an educated guess at where the module
should be.  After that, look at every available file to find a match.

=cut

sub process {

    my $self      = shift;
    my $success   = 0;
    my $module_rs = $self->modules;

MODULE:
    while ( my $found = $module_rs->next ) {

        say "checking dist " . $found->name if $self->debug;

        $self->module(
            iCPAN::Module->new(
                metadata => $found,
                tar      => $self->tar,
                schema   => $self->schema
            )
        );

        # take an educated guess at the correct file before we go through the
        # entire list

        my $base_guess = 'lib/' . $found->name;
        $base_guess =~ s{::}{/}g;

        foreach my $extension ( '.pm', '.pod' ) {
            my $guess = $base_guess . $extension;
            if ( $self->validate_file( $guess ) ) {
                say "*" x 10 . " found guess: $guess" if $self->debug;
                ++$success;
                next MODULE;
            }

        }

    FILE:
        foreach my $file ( sort keys %{ $self->files } ) {
            print "checking: $file " if $self->debug;
            if ( $self->debug ) {
                say "#" x 20;
                say "found files: " . scalar keys %{ $self->files };
            }
            next FILE if !$self->validate_file( $file );

            say "found : $file ";
            ++$success;
            next MODULE;
        }

    }

    $self->process_cookbooks;

    if ( !$success && $self->debug ) {
        warn $self->name . " no success" . "!" x 20;
    }

    $self->tar->clear if $self->tar;
    return;

}

=head2 modules

We only care about modules which are in the very latest version of the distro.
For example, the minicpan (and CPAN) indices, show something like this:

Moose::Meta::Attribute::Native     1.17  D/DR/DROLSKY/Moose-1.17.tar.gz
Moose::Meta::Attribute::Native::MethodProvider::Array 1.14  D/DR/DROLSKY/Moose-1.14.tar.gz

We don't care about modules which are no longer included in the latest
distribution, so we'll only import POD from the highest version number of any
distro we're searching on.

=cut

sub modules {

    my $self = shift;
    my $name = $self->name;
    $name =~ s{::}{-}g;
    $self->name( $name );

    my $rs = $self->meta_index->schema->resultset(
        'iCPAN::Meta::Schema::Result::Module' );

    # I'm sure there is a better way of doing this (GROUP BY?)
    my $latest = $rs->search( { dist => $self->name },
        { order_by => 'distvname DESC' } )->first;

    return $rs->search( { distvname => $latest->distvname } );

}

=head2 validate_file

Remove the file from the list of pkg files if it can be processed

=cut

sub validate_file {

    my $self     = shift;
    my $filename = shift;

    return 0 if !exists $self->files->{$filename};
    return 0 if !$self->module->process( $filename );

    say "found : $filename ";
    delete $self->files->{$filename};

}

=head2 process_cookbooks

Because manuals and cookbook pages don't appear in the minicpan index, they
were passed over previous to 1.0.2

This should be run on any files left over in the distribution.

=cut

sub process_cookbooks {

    my $self = shift;

    foreach my $file ( sort keys %{ $self->files } ) {
        next if $file !~ m{\.pod};

        my $module_name = $self->file2mod( $file );

        # no need to create author entry.  that will be handled by Module.pm
        my $found
            = $self->meta_index->schema->resultset(
            'iCPAN::Meta::Schema::Result::Module' )
            ->find( { name => $module_name } );

        if ( !$found ) {
            $found = $self->metadata->copy( { name => $module_name } );
        }

        $self->module(
            iCPAN::Module->new(
                metadata => $found,
                tar      => $self->tar,
                schema   => $self->schema
            )
        );

        my $success = $self->module->process( $file );
        say '=' x 20 . " found cookbook: " . $file if $self->debug;
    }

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

    my @files  = $tar->list_files;
    my %files  = ();
    my $parent = $self->metadata->distvname . '/';

    if ( $self->debug ) {
        say '^' x 20 . "building files";
        my %cols = $self->metadata->get_columns;
        say dump( \%cols );
    }

    foreach my $file ( @files ) {
        if ( $file =~ m{\.(pod|pm)\z}i ) {

            $file =~ s{\A$parent}{};
            $files{$file} = 1;
        }
    }

    say dump( \%files ) if $self->debug;
    return \%files;

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
