package iCPAN;

use Moose;

use CHI;
use Data::Printer;
use File::Slurp;
use LWP::ConsoleLogger::Easy qw( debug_ua );
use MetaCPAN::Pod;
use Modern::Perl;
use Parallel::ForkManager;
use Perl6::Junction qw( any );
use Search::Elasticsearch;
use Try::Tiny;
use Types::Standard qw( Bool InstanceOf Int Str );
use Types::URI -all;
use WWW::Mechanize;
use WWW::Mechanize::Cached;

with( 'iCPAN::Role::DB', 'iCPAN::Role::Common', 'MooseX::Getopt::Dashes' );

use iCPAN::Schema;

has action => (
    is        => 'ro',
    isa       => Str,
    predicate => 'has_action',
);

has children => (
    is      => 'ro',
    isa     => Int,
    default => 2
);

has dist_search_prefix => (
    is      => 'ro',
    isa     => Str,
    default => 'DBIx-Class',
);

has distribution_scroll_size => (
    is      => 'ro',
    isa     => Int,
    default => 1000
);

has es => (
    is      => 'ro',
    isa     => InstanceOf ['Search::Elasticsearch::Client::1_0::Direct'],
    lazy    => 1,
    builder => '_build_es',
);

has index => (
    is      => 'ro',
    isa     => Str,
    default => 'v0'
);

has limit => (
    is      => 'ro',
    isa     => Int,
    default => 100000
);

has mech => (
    is      => 'ro',
    isa     => InstanceOf ['WWW::Mechanize'],
    lazy    => 1,
    handles => { get => 'get' },
    builder => '_build_mech',
);

has module_scroll_size => (
    is      => 'ro',
    isa     => Int,
    default => 1000
);

has pod_server => (
    is      => 'ro',
    isa     => Uri,
    coerce  => 1,
    default => 'http://localhost:5000/podpath/'
);

has purge => (
    is      => 'ro',
    isa     => Int,
    default => 0
);

has scroll_size => (
    is      => 'ro',
    isa     => Int,
    default => 1000
);

has search_prefix => (
    is      => 'ro',
    isa     => Str,
    default => 'DBIx::Class'
);

has server => (
    is      => 'ro',
    isa     => Str,
    default => 'api.metacpan.org'
);

has update_undef_only => (
    is      => 'ro',
    isa     => Bool,
    default => 0
);

my @ROGUE_DISTRIBUTIONS
    = qw(kurila perl_debug perl-5.005_02+apache1.3.3+modperl pod2texi perlbench spodcxx);

sub _build_es {
    my $self = shift;

    my $es = Search::Elasticsearch->new(
        cxn          => 'NetCurl',
        cxn_pool     => 'Static::NoPing',
        max_requests => 0,                  # default 10_000
        nodes        => $self->server,
        no_refresh   => 1,
        servers      => $self->server,
    );

    return $es;
}

sub _build_mech {
    my $self = shift;

    my $folder = "$ENV{HOME}/tmp/iCPAN";
    my $cache  = CHI->new(
        driver     => 'FastMmap',
        root_dir   => $folder,
        cache_size => '800m'
    );

    my $mech = WWW::Mechanize::Cached->new( autocheck => 0, cache => $cache );

    #my $mech = WWW::Mechanize->new( autocheck => 0 );
    debug_ua($mech) if $self->debug;
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

        p $hits[-1] if $self->debug;
        say @hits . ' results so far' if $self->debug;

        last if scalar @hits >= $limit;
    }

    return \@hits;
}

sub insert_authors {
    my $self = shift;
    my $rs   = $self->init_rs('Zauthor');

    my $scroller = $self->es->scroll_helper(
        index  => $self->index,
        type   => 'author',
        body   => { query => { match_all => {}, } },
        fields => [ 'pauseid', 'name', 'email' ],
        scroll => '5m',
        size   => 1000,
    );

    my $hits = $self->scroll( $scroller, 20000 );
    my @authors = ();

    say "found " . scalar @{$hits} . " hits";
    my $ent = $self->get_ent('Author');

    foreach my $src ( @{$hits} ) {

        p $src if $self->debug;
        push @authors,
            {
            z_ent    => $ent->z_ent,
            z_opt    => 1,
            zpauseid => $src->{pauseid},
            zname    => ( ref $src->{name} ) ? undef : $src->{name},
            zemail   => ref $src->{email}
            ? shift @{ $src->{email} }
            : $src->{email},
            };
    }

    $rs->populate( \@authors );
    $self->update_ent( $rs, $ent );
    return;

}

sub insert_distributions {
    my $self = shift;
    my $rs   = $self->init_rs('Zdistribution');

    my $scroller = $self->es->scroll_helper(
        index => $self->index,
        type  => ['release'],
        body  => {
            query => { term => { status => 'latest' } },
            filter =>
                { prefix => { distribution => $self->dist_search_prefix } },
            fields => [
                'author', 'distribution', 'abstract', 'version_numified',
                'name',   'date'
            ],
        },
        scroll  => '30m',
        size    => $self->distribution_scroll_size,
        explain => 0,
    );

    my $hits = $self->scroll( $scroller, 100_000 );
    my @rows = ();

    say "found " . scalar @{$hits} . " hits" if $self->debug;

    my $ent = $self->get_ent('Distribution');

    foreach my $src ( @{$hits} ) {
        p $src if $self->debug;

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

=head2 insert_modules

Do bulk inserts of all modules returned by the API. Fetch Pod later.
This allows us to cut down on expensive API calls as well as avoiding
a constantly changing list of modules.

=cut

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
            my $dist = $dist_rs->find_or_create(
                { zname => $src->{distribution} },
                { rows  => 1 }
            );

            if ( $dist->id ) {
                $dist_id{ $src->{distribution} } = $dist->id;
            }
            else {
                $dist_id{ $src->{distribution} } = $dist_rs->update(
                    {
                        zauthor       => $src->{author},
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

=head2 pod_by_dist

Updates all of the Pod in the db on a per dist basis.  We generally want to
truncate the Pod table before proceeding, so that we don't have Pod pointing to
the wrong Module.

=cut

sub pod_by_dist {
    my $self = shift;
    my $zpod = $self->init_rs('Zpod');                # truncates Pod table
    my $rs   = $self->schema->resultset('Zmodule');

    my %search = ();
    if ( $self->update_undef_only ) {
        $search{'Modules.zpod'} = undef;
    }
    my $dist_rs = $self->schema->resultset('Zdistribution')->search(
        \%search,
        {
            join     => [ 'Author', 'Modules' ],
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

        $self->update_pod_in_single_dist($dist);
    }

    my $pod_rs = $self->schema->resultset('Zpod');
    $self->update_ent( $pod_rs, $self->get_ent('Pod') );
}

sub update_pod_in_single_dist {
    my $self = shift;
    my $dist = shift;

    my $converter = MetaCPAN::Pod->new;

    my %search = ();
    $search{zpod} = undef if $self->update_undef_only;

    my $mod_rs = $dist->Modules( \%search );
    $converter->build_tar( $dist->Author->zpauseid, $dist->zrelease_name );

    my $found = 0;
MODULE:
    while ( my $mod = $mod_rs->next ) {
        say "starting module: " . $mod->zpath;

        my $relative_url = join(
            "/",
            $dist->Author->zpauseid,
            $dist->zrelease_name, $mod->zpath
        );

        my $pod;

        # There was some code here that was supposed to find a cached version
        # using a local web service, but it only returns 404s.  We'd have to
        # tweak the web service to do the below:
        #
        # 1) Try to get the pod locally 2) Try to fetch the source from
        # MetaCPAN
        #
        # The whole caching this is too convoluted.

        try {
            $pod = $converter->pod_from_tar(
                $dist->zrelease_name,
                $mod->zpath
            );
        }
        catch {
            say "local pod error: $_";
        };

        if ($pod) {
            my $xhtml;
            try { $xhtml = $converter->parse_pod($pod) }
            catch { say "*************** could not parse pod" };

            if ($xhtml) {
                my $pod_row = $mod->find_or_create_related(
                    'Pod',
                    { zhtml => $xhtml }
                );
                $mod->update( { zpod => $pod_row->id } );
                ++$found;
                next MODULE;
            }
        }

        if ( $self->mech->get( $self->pod_server . $relative_url )
            ->is_success ) {
            my $pod_row = $mod->find_or_create_related(
                'Pod',
                { zhtml => $self->mech->content }
            );
            $mod->update( { zpod => $pod_row->id } );
        }
        else {
            say "==============> could not find MetaCPAN Pod";
        }
    }
    return $found;
}

=head2 finish_db

Perform some final db cleanup.  Mostly this needs to be done in order to have
valid metadata in the db which Core Data relies on.

=cut

sub finish_db {
    my $self   = shift;
    my $pod_rs = $self->schema->resultset('Zmodule')->search(
        { 'Pod.ZHTML' => undef },
        { order_by    => 'zname ASC', prefetch => 'Pod' }
    );

    my @missing;
    while ( my $module = $pod_rs->next ) {
        push @missing, $module->zname;
    }

    write_file( 'MISSING_MODULES.txt', join( "\n", @missing ) );

    $pod_rs->reset;
    $pod_rs->delete;

    foreach my $table ( 'author', 'distribution', 'module', 'pod' ) {
        my $name = "Z$table";
        my $rs   = $self->schema->resultset($name);
        $self->update_ent( $rs, $self->get_ent($name) );
    }

    $self->schema->storage->dbh->do("VACUUM");
}

sub module_scroller {
    my $self = shift;
    return $self->es->scroll_helper(
        index => $self->index,
        type  => ['file'],

        body => {
            query => { "match_all" => {} },

            filter => {
                and => [
                    {
                        not => {
                            filter => {
                                or => [
                                    map {
                                        { term =>
                                                { 'file.distribution' => $_ }
                                        }
                                    } @ROGUE_DISTRIBUTIONS
                                ]
                            }
                        }
                    },
                    { term => { status => 'latest' } },
                    {
                        or => [

                            # we are looking for files that have no authorized
                            # property (e.g. .pod files) and files that are
                            # authorized
                            { missing => { field => 'file.authorized' } },
                            { term => { 'file.authorized' => \1 } },
                        ]
                    },
                    {
                        or => [
                            {
                                and => [
                                    {
                                        exists =>
                                            { field => 'file.module.name' }
                                    },
                                    {
                                        term =>
                                            { 'file.module.indexed' => \1 }
                                    }
                                ]
                            },
                            {
                                and => [
                                    {
                                        exists => { field => 'documentation' }
                                    },
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
        },
        scroll  => '15m',
        size    => $self->module_scroll_size,
        explain => 0,
    );
}

=head2 init_rs( $dbic_table_name )

Truncates table if required.  Returns a resultset for the table.

=cut

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
