package iCPAN;

use DBI;
use Find::Lib;
use iCPAN::Schema;
use Moose;
use Modern::Perl;

has 'schema' => (
    is         => 'ro',
    isa        => 'iCPAN::Schema',
    lazy_build => 1,
);

has 'db_file' => (
    is => 'rw',
    isa => 'Str',
    lazy_build => 1,
);

has 'dbh' => (
    is         => 'rw',
    isa        => 'DBI::db',
    lazy_build => 1,
);

has 'dsn' => (
    is      => 'rw',
    isa     => 'Str',
    default => sub { my $self = shift; return "dbi:SQLite:dbname=" . $self->db_file },
);

sub mod2file {

    my $self        = shift;
    my $module_name = shift;

    my $file = $module_name;
    $file =~ s{::}{-}gxms;
    $file .= '.html';

    return $file;
}

sub _build_schema {

    my $self    = shift;


    my $dsn = "dbi:SQLite:dbname=../iCPAN.sqlite";
    my $schema = iCPAN::Schema->connect( $self->dsn, '', '', '' );
    return $schema;
}

sub _build_dbh {

    my $self = shift;
    return DBI->connect( $self->dsn, "", "" );
}

sub _build_db_file {
    
    my $self = shift;
    my $db_file = Find::Lib->base . '/../../iCPAN.sqlite';

    if ( !-e $db_file ) {
        die "$db_file not found";
    }
    
    return $db_file;
    
}

1;
