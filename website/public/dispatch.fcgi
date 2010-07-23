#!/Users/olaf/local/bin/perl
use Plack::Handler::FCGI;

my $app = do('/Users/olaf/Documents/developer/iphone/iCPAN/app/iCPANWeb/app.psgi');
my $server = Plack::Handler::FCGI->new(nproc  => 5, detach => 1);
$server->run($app);
