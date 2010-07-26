#!/usr/bin/env perl
use Plack::Runner;
use Find::Lib '../../perl/lib/', '../lib';

Plack::Runner->run( Find::Lib->base . '/../app.psgi');
