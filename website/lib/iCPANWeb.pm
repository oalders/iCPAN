package iCPANWeb;
use Dancer ':syntax';
use Data::Dump qw( dump );
use iCPAN;
use WWW::Mechanize::Cached;

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
    
    if ( $module ) {
        my $pod = $module->zpod;
        $pod =~ s{shThemeEmacs}{shThemeDefault};
        $pod =~ s{background-color: #000}{background-color: #fff;border: 1px solid #999;};
#        $pod =~ s{background-color: #000}{background-color: #fff};

#        $pod =~ s{false}{false;SyntaxHighlighter.defaults\['toolbar'\] = false};
        return $pod;
    }

    status 'not_found';
    return 'Not found';

};

get '/source/:name' => sub {

    my $icpan = icpan();
    my $name = params->{name};
    $name =~ s{[-']}{::}g;
    $name =~ s{\.html\z}{};

    my $rs = $icpan->schema->resultset( 'iCPAN::Schema::Result::Zmodule' );
    #my $module = $rs->find( { 'lower(me.zname)' => lc($name) } );
    my $module = $rs->find( { zname => $name } );
    vars->{source} = 'source goes here';
    #layout 'source';

};

sub icpan {

    my $icpan = iCPAN->new;
    $icpan->db_path( '/Users/olaf/Documents/developer/iphone/iCPAN/iCPAN.sqlite' );
    return $icpan;

}

true;
