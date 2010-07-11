package iCPAN;

use DBI;
use iCPAN::Schema;
use Moose;
use Modern::Perl;

has 'schema' => (
    is => 'ro',
    isa => 'iCPAN::Schema',
    lazy_build => 1,
);

sub mod2file {

    my $self        = shift;
    my $module_name = shift;

    my $file = $module_name;
    $file =~ s{::}{-}gxms;
    $file .= '.html';

    #say "got $module_name";
    #say "returning $file";

    return $file;
}

sub _build_schema {

    my $self = shift;
    my $dsn    = "dbi:SQLite:dbname=../iCPAN.sqlite";
    my $dbh    = DBI->connect( $dsn, "", "" );
    my $schema = iCPAN::Schema->connect( $dsn, '', '', '' );
    return $schema;
}

1;
