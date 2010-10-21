package iCPAN::Meta;

use Moose;

with 'iCPAN::Role::DB';

use Data::Dump qw( dump );
use iCPAN::Meta::Schema;
use Modern::Perl;

has 'db_path' => (
    is      => 'rw',
    isa     => 'Str',
    default => '../../iCPAN-meta.sqlite',
);

has 'schema' => (
    is         => 'ro',
    isa        => 'iCPAN::Meta::Schema',
    lazy_build => 1,
);

sub _build_schema {

    my $self   = shift;
    my $dsn    = "dbi:SQLite:dbname=" . $self->db_file;
    my $schema = iCPAN::Meta::Schema->connect( $self->dsn, '', '', '' );
    return $schema;
}

1;
