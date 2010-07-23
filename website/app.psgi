# PSGI application bootstrapper for Dancer
use Dancer;
load_app 'iCPANWeb';

use Find::Lib '../perl/lib';

use Dancer::Config 'setting';
setting apphandler  => 'PSGI';
Dancer::Config->load;

my $handler = sub {
    my $env = shift;
    my $request = Dancer::Request->new($env);
    Dancer->dance($request);
};
