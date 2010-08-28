# PSGI application bootstrapper for Dancer
# you can fire it up like this: plackup -Ilib -I../perl/lib

use Dancer;
load_app 'iCPANWeb';

use Dancer::Config 'setting';
setting apphandler  => 'PSGI';
Dancer::Config->load;

my $handler = sub {
    my $env = shift;
    my $request = Dancer::Request->new($env);
    Dancer->dance($request);
};
