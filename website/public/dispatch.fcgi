#!/usr/bin/env perl
use Plack::Handler::FCGI;

use Find::Lib '../../perl/lib/', '../lib';

my $app = do( Find::Lib->base . '/../app.psgi' );
my $server = Plack::Handler::FCGI->new(nproc  => 5, detach => 1);
$server->run($app);
