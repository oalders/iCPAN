package iCPANWeb;
use Dancer ':syntax';
use Data::Dump qw( dump );
use iCPAN;

our $VERSION = '0.1';

get '/' => sub {
    template 'index';
};

get '/env' => sub {
    return '<pre>' . dump( \%ENV ) . '</pre>';
};

get '/docs/*.css' => sub {
    my ( $file ) = splat;
    redirect "/css/$file.css";
};


get '/docs/*.js' => sub {
    my ( $file ) = splat;
    redirect "/js/$file.js";
};

get '/docs/:name' => sub {

    my $icpan = icpan();
    my $name = params->{name};
    $name =~ s{[-']}{::}g;
    $name =~ s{\.html\z}{};

    my $rs = $icpan->schema->resultset( 'iCPAN::Schema::Result::Zmodule' );
    #my $module = $rs->find( { 'lower(me.zname)' => lc($name) } );
    my $module = $rs->find( { zname => $name } );
    return $module->zpod if $module;

    status 'not_found';
    return 'Not found';

};

sub icpan {

    my $icpan = iCPAN->new;
    $icpan->db_path( '/../iCPAN.sqlite' );
    return $icpan;

}

true;
