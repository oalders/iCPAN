package iCPAN;
use Moose;

with 'iCPAN::Role::DB';

use Archive::Tar;
use CPAN::DistnameInfo;
use Data::Dump qw( dump );
use DBI;
use Find::Lib;
use iCPAN::Module;
use iCPAN::Pod::XHTML;
use iCPAN::Schema;
use IO::Uncompress::AnyInflate qw(anyinflate $AnyInflateError);
use Modern::Perl;

has 'schema' => (
    is         => 'ro',
    isa        => 'iCPAN::Schema',
    lazy_build => 1,
);

has 'db_path' => (
    is      => 'rw',
    isa     => 'Str',
    default => '../../iCPAN.sqlite',
);

has 'debug' => (
    is         => 'rw',
    lazy_build => 1,
);

has 'module_name' => (
    is  => 'rw',
    isa => 'Str',
);

has 'minicpan' => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);

has 'pkg_index' => (
    is => 'rw',

    #isa => 'Hashref',
    lazy_build => 1,
);

sub mod2file {

    my $self        = shift;
    my $module_name = shift;

    my $file = $module_name;
    $file =~ s{::}{-}gxms;
    $file .= '.html';

    return $file;
}

sub open_pkg_index {

    my $self = shift;
    my $file = $self->minicpan . '/modules/02packages.details.txt.gz';
    my $tar  = Archive::Tar->new;

    my $z = new IO::Uncompress::AnyInflate $file
        or die "anyinflate failed: $AnyInflateError\n";

    return $z;

}

sub _build_pkg_index {

    my $self  = shift;
    my $file  = $self->open_pkg_index;
    my %index = ();

    my $skip = 1;

LINE:
    while ( my $line = $file->getline ) {
        if ( $skip ) {
            $skip = 0 if $line eq "\n";
            next LINE;
        }

        my ( $module, $version, $archive ) = split m{\s{1,}}xms, $line;

        # DistNameInfo converts 1.006001 to 1.6.1
        my $d = CPAN::DistnameInfo->new( $archive );

        $index{$module} = {
            archive => $d->pathname,
            version => $d->version,
            pauseid => $d->cpanid,
            dist    => $d->dist,
        };
    }

    return \%index;

}


sub _build_schema {

    my $self   = shift;
    my $dsn    = "dbi:SQLite:dbname=" . $self->db_file;
    my $schema = iCPAN::Schema->connect( $self->dsn, '', '', '' );
    return $schema;
}

sub _build_debug {

    my $self = shift;
    return $ENV{'DEBUG'} || 0;

}

sub _build_minicpan {

    my $self = shift;
    return $ENV{'MINICPAN'} || "$ENV{'HOME'}/minicpan";

}

sub module {

    my $self = shift;

    die "module name missing" if !$self->module_name;
    my $ref = $self->pkg_index->{ $self->module_name };
    return if !$ref;

    return iCPAN::Module->new(
        %{$ref},
        name   => $self->module_name,
        debug  => $self->debug,
        icpan  => $self,
        schema => $self->schema,
    );

}

1;
