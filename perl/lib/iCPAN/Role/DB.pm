package iCPAN::Role::DB;

use Modern::Perl;
use Moose::Role;
use DBI;
use Find::Lib;

has 'db_file' => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);

has 'dsn' => (
    is         => 'rw',
    isa        => 'Str',
    lazy_build => 1,
);

has 'schema' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'schema_class' => (
    is      => 'rw',
    default => 'iCPAN::Schema',
);

has 'meta_index' => (
    is         => 'rw',
    lazy_build => 1,
);

sub _build_meta_index {

    my $self = shift;
    my $meta = iCPAN::MetaIndex->new();
    $meta->schema_class( 'iCPAN::Meta::Schema' );
    
    say "meta index " . "*"x80;
    return $meta;
}

sub _build_dsn {

    my $self = shift;
    return "dbi:SQLite:dbname=" . $self->db_file;

}

sub _build_db_file {

    my $self   = shift;
    my @caller = caller();

    my $db_file = Find::Lib::base() . '/' . $self->db_path;

    if ( !-e $db_file ) {
        die "$db_file not found";
    }

    return $db_file;

}

sub _build_schema {

    my $self   = shift;
    my $schema = $self->schema_class->connect( $self->dsn, '', '', '',
        { sqlite_use_immediate_transaction => 1, AutoCommit => 1 } );

    #$schema->storage->dbh->sqlite_busy_timeout(0);
    return $schema;
}

1;
