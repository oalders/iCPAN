package iCPAN;

use CHI;
use Data::Dump qw( dump );
use ElasticSearch;
use MetaCPAN::Pod;
use Modern::Perl;
use Moose;
use Parallel::ForkManager;
use Perl6::Junction qw( any );
use Try::Tiny;
use WWW::Mechanize;
use WWW::Mechanize::Cached;

with 'iCPAN::Role::DB';
with 'iCPAN::Role::Common';

use iCPAN::Schema;

# ssh -L 9201:localhost:9200 metacpan@api.beta.metacpan.org -p222 -N

has 'children' => ( is => 'rw', isa => 'Int', default => 2 );
has 'cached_pod' =>
    ( is => 'rw', default => 'http://localhost:5000/is_cached/' );
has 'dist_search_prefix' =>
    ( is => 'rw', isa => 'Str', default => 'DBIx-Class' );
has 'distribution_scroll_size' =>
    ( is => 'rw', isa => 'Int', default => 1000 );
has 'es' => ( is => 'rw', isa => 'ElasticSearch', lazy_build => 1 );
has 'index' => ( is => 'rw', default => 'v0' );
has 'limit' => ( is => 'rw', isa     => 'Int', default => 100000 );
has 'mech'  => ( is => 'rw', isa     => 'WWW::Mechanize', lazy_build => 1 );
has 'module_scroll_size' => ( is => 'rw', isa => 'Int', default => 1000 );
has 'pod_server' =>
    ( is => 'rw', default => 'http://localhost:5000/podpath/' );
has 'purge'         => ( is => 'rw', isa => 'Int', default => 0 );
has 'scroll_size'   => ( is => 'rw', isa => 'Int', default => 1000 );
has 'search_prefix' => ( is => 'rw', isa => 'Str', default => 'DBIx::Class' );
has 'server' => ( is => 'rw', default => 'api.beta.metacpan.org:80' );
has 'update_undef_only' => ( is => 'rw', default => 0 );

my @ROGUE_DISTRIBUTIONS
    = qw(kurila perl_debug perl-5.005_02+apache1.3.3+modperl pod2texi perlbench spodcxx);

sub _build_es {

    my $self = shift;

    return ElasticSearch->new(
        servers      => $self->server,
        transport    => 'curl',
        max_requests => 0,               # default 10_000
        trace_calls  => 'log_file',
        no_refresh   => 1,
    );

}

sub _build_mech {

    my $self = shift;

    my $folder = "$ENV{HOME}/tmp/iCPAN";
    my $cache  = CHI->new(
        driver     => 'FastMmap',
        root_dir   => $folder,
        cache_size => '800m'
    );

   #my $mech = WWW::Mechanize::Cached->new( autocheck => 0, cache => $cache );

    my $mech = WWW::Mechanize->new( autocheck => 0 );
    return $mech;

}

sub scroll {

    my $self     = shift;
    my $scroller = shift;
    my $limit    = shift || 100;
    my @hits     = ();

    while ( my $result = $scroller->next ) {

        push @hits, exists $result->{'_source'}
            ? $result->{'_source'}
            : $result->{fields};

        #say dump $hits[-1];
        #say @hits . ' results so far';

        last if scalar @hits > $limit;

    }

    return \@hits;
}

sub insert_authors {

    my $self = shift;

    my $rs = $self->schema->resultset('Zauthor');
    if ( $self->purge ) {
        $rs->delete;
        $self->schema->storage->dbh->do("VACUUM");
    }

    my $scroller = $self->es->scrolled_search(
        index  => $self->index,
        type   => 'author',
        query  => { match_all => {}, },
        scroll => '5m',
        size   => 5000,
    );

    my $hits = $self->scroll( $scroller, 10000 );
    my @authors = ();

    say "found " . scalar @{$hits} . " hits";
    my $ent = $self->get_ent('Author');

    foreach my $src ( @{$hits} ) {

        #say dump $src;
        push @authors,
            {
            z_ent    => $ent->z_ent,
            z_opt    => 1,
            zpauseid => $src->{pauseid},
            zname    => ( ref $src->{name} ) ? undef : $src->{name},
            zemail   => shift @{ $src->{email} },
            };
    }

    $rs->populate( \@authors );
    $self->update_ent( $rs, $ent );
    return;

}

sub insert_distributions {

    my $self = shift;
    my $rs   = $self->schema->resultset('Zdistribution');
    $rs->delete if $self->purge;

    my $scroller = $self->es->scrolled_search(
        index => $self->index,
        type  => ['release'],
        query => {
            term => { status => 'latest' },

            #match_all => {},
        },
        filter => { prefix => { distribution => $self->dist_search_prefix } },
        fields => [
            'author', 'distribution', 'abstract', 'version_numified',
            'name',   'date'
        ],
        scroll  => '30m',
        size    => $self->distribution_scroll_size,
        explain => 0,
    );

    my $hits = $self->scroll( $scroller, 30000 );
    my @rows = ();

    say "found " . scalar @{$hits} . " hits";

    my $ent = $self->get_ent('Distribution');

    foreach my $src ( @{$hits} ) {

        #say dump $src;

        my $author = $self->schema->resultset('Zauthor')
            ->find( { zpauseid => $src->{author} } );
        if ( !$author ) {
            say "cannot find $src->{author}. skipping!!!";
            next;
        }

        push @rows,
            {
            z_ent         => $ent->z_ent,
            z_opt         => 1,
            zabstract     => $src->{abstract},
            zauthor       => $author->z_pk,
            zrelease_date => $src->{date},
            zrelease_name => $src->{name},
            zversion      => $src->{version_numified},
            zname         => $src->{distribution},
            };

        if ( scalar @rows >= $self->distribution_scroll_size ) {
            $rs->populate( \@rows );
            @rows = ();
            say "rows in db: " . $rs->search( {} )->count;
        }

    }

    $rs->populate( \@rows ) if @rows;
    $self->update_ent( $rs, $ent );
    return;

}

sub insert_modules {

    my $self    = shift;
    my $rs      = $self->init_rs('Zmodule');
    my $dist_rs = $self->schema->resultset('Zdistribution');

    my $scroller = $self->module_scroller;

    my $ent = $self->get_ent('Module');

    my %dist_id = ();
    my @hits    = ();
    my @rows    = ();
    while ( my $result = $scroller->next ) {

        my $src = $self->extract_hit($result);
        next if !$src;
        next if !$src->{documentation};

        # TODO why are there multiple dists with the same name in this table?
        if ( !exists $dist_id{ $src->{distribution} } ) {
            my $dist
                = $dist_rs->find_or_create( { zname => $src->{distribution} },
                { rows => 1 } );

            if ( $dist->id ) {
                $dist_id{ $src->{distribution} } = $dist->id;
            }
            else {
                $dist_id{ $src->{distribution} } = $dist_rs->update(
                    {   zauthor       => $src->{author},
                        zrelease_date => $src->{date},
                        zname         => $src->{distribution},
                        zversion      => $src->{version_numified},
                        zabstract => $src->{abstract} || 'abstract missing',
                    }
                )->id;
            }
        }

        my $insert = {
            z_ent     => $ent->z_ent,
            z_opt     => 1,
            zabstract => $src->{'abstract.analyzed'} || 'abstract missing',
            zdistribution => $dist_id{ $src->{distribution} },
            zname         => $src->{documentation},
            zpath         => $src->{path},
        };
        push @rows, $insert;

        if ( scalar @rows >= $self->module_scroll_size ) {
            $rs->populate( \@rows );
            @rows = ();
            say "rows in db: " . $rs->search( {} )->count;
        }

    }

    $rs->populate( \@rows ) if @rows;

    $self->update_ent( $rs, $ent );

    return;

}

sub extract_hit {

    my $self   = shift;
    my $result = shift;

    return exists $result->{'_source'}
        ? $result->{'_source'}
        : $result->{fields};

}

sub get_ent {

    my $self  = shift;
    my $table = shift;

    return $self->schema->resultset('ZPrimarykey')
        ->find_or_create( { z_name => $table } );

}

sub update_ent {

    my ( $self, $rs, $ent ) = @_;
    my $last = $rs->search( {}, { order_by => 'z_pk DESC' } )->first;
    $ent->z_max( $last->id );
    $ent->update;

}

sub pod_by_dist {

    my $self = shift;
    my $rs   = $self->schema->resultset( 'Zmodule' );

    my %search = ( );
    if ( $self->update_undef_only ) {
        $search{'Modules.zpod'} = undef;
    }
    my $dist_rs = $self->schema->resultset( 'Zdistribution' )->search(
        \%search,
        {   join     => [ 'Author', 'Modules' ],
            group_by => [qw/zrelease_name/],
            order_by => 'zrelease_date DESC',
        }
    );

    my $total_dists = $dist_rs->count;
    my $dist_count  = 0;
    say "looking at $total_dists dists";

    while ( my $dist = $dist_rs->next ) {
        ++$dist_count;

        say "starting dist $dist_count of $total_dists: "
            . $dist->zrelease_name;

        $self->update_pod_in_single_dist( $dist );
    }

    my $pod_rs = $self->schema->resultset( 'Zpod' );
    $self->update_ent( $pod_rs, $self->get_ent( 'Pod' ) );
}

sub update_pod_in_single_dist {

    my $self = shift;
    my $dist = shift;

    my $converter = MetaCPAN::Pod->new;

    my %search = ( );
    $search{zpod} = undef if $self->update_undef_only;

    my $mod_rs = $dist->Modules( \%search );
    $converter->build_tar( $dist->Author->zpauseid, $dist->zrelease_name );

    while ( my $mod = $mod_rs->next ) {
        say "starting module: " . $mod->zpath;

        my $relative_url = join( "/",
            $dist->Author->zpauseid, $dist->zrelease_name, $mod->zpath );

        my $pod = undef;
        $self->mech->get( $self->cached_pod . $relative_url );

        if ( $self->mech->success ) {
            $pod = $self->mech->content;
        }
        else {
            try {
                $pod = $converter->pod_from_tar( $dist->zrelease_name,
                    $mod->zpath );
            }
            catch {
                say "local pod error: $_";    # not $@
            };
        }

        if ( $pod ) {
            my $xhtml;
            try { $xhtml = $converter->parse_pod( $pod ) };
            catch { say "*************** could not parse pod" };

            if ( $xhtml ) {
                my $pod_row = $mod->find_or_create_related( 'Pod',
                    { zhtml => $xhtml } );
                $mod->update( { zpod => $pod_row->id } );
                next;
            }
        }

        if ( $self->mech->get( $self->pod_server . $relative_url )
            ->is_success )
        {
            my $pod_row = $mod->find_or_create_related( 'Pod',
                { zhtml => $self->mech->content } );
            $mod->update( { zpod => $pod_row->id } );
        }
        else {
            say "==============> could not find MetaCPAN Pod";
        }

    }
}

sub module_scroller {

    my $self = shift;
    return $self->es->scrolled_search(
        index => $self->index,
        type  => ['file'],

        query => { "match_all" => {} },

        filter => {
            and => [
                {   not => {
                        filter => {
                            or => [
                                map {
                                    { term => { 'file.distribution' => $_ } }
                                    } @ROGUE_DISTRIBUTIONS
                            ]
                        }
                    }
                },
                { term => { status => 'latest' } },
                {   or => [

                        # we are looking for files that have no authorized
                        # property (e.g. .pod files) and files that are
                        # authorized
                        { missing => { field => 'file.authorized' } },
                        { term => { 'file.authorized' => \1 } },
                    ]
                },
                {   or => [
                        {   and => [
                                { exists => { field => 'file.module.name' } },
                                { term => { 'file.module.indexed' => \1 } }
                            ]
                        },
                        {   and => [
                                { exists => { field => 'documentation' } },
                                { term => { 'file.indexed' => \1 } }
                            ]
                        }
                    ]
                }
            ]
        },

        sort   => [ { "date" => "desc" } ],
        fields => [
            "abstract.analyzed", "documentation",
            "distribution",      "date",
            "author",            "release",
            "path"
        ],
        scroll  => '15m',
        size    => $self->module_scroll_size,
        explain => 0,
    );

}

sub init_rs {

    my $self = shift;
    my $name = shift;
    my $rs   = $self->schema->resultset($name);

    if ( $self->purge ) {
        $rs->delete;
        $self->schema->storage->dbh->do("VACUUM");
    }

    return $rs;
}

1;

=pod

=head2 init_rs( $dbic_table_name )

Truncates table if required.  Returns a resultset for the table.

=head2 insert_modules

Do bulk inserts of all modules returned by the API. Fetch Pod later.
This allows us to cut down on expensive API calls as well as avoiding
a constantly changing list of modules.

=cut
