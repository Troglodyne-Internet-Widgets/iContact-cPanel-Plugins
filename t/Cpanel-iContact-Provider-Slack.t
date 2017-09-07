use strict;
use warnings;

use Cwd qw{abs_path};
use File::Basename qw{dirname};
use lib abs_path( dirname(__FILE__) . "/../lib" );

use Test::More;
use Test::Fatal;
use Test::MockModule();
use Test::NoWarnings;

-d "/usr/local/cpanel" ? plan tests => 4 : plan SKIP_ALL => "cPanel not installed";    # 3 + 1 for NoWarnings

require Cpanel::HTTP::Client;
require Cpanel::HTTP::Client::Response;
require Cpanel::iContact::Provider::Slack;


# First, let's mock out the parent, and other stuff we wouldn't wanna do in a unit test
my $provider    = Test::MockModule->new("Cpanel::iContact::Provider");
my $text_scalar = 'lol, jk';
my $send_args   = { 'subject' => "[test.host.tld] YOUR COMIC BOOKS ARE DYING!!!1", 'text_body' => \$text_scalar, 'to' => [ 'SalinasPunishmentRoom', '@cPSaurus' ] };
my $contact_cfg = {};
$provider->mock( 'new' => sub { return bless { 'args' => $send_args, 'contact' => $contact_cfg }, "Cpanel::iContact::Provider::Slack"; } );
my $ua_mocker = Test::MockModule->new("Cpanel::HTTP::Client");
$ua_mocker->mock( 'post_form' => sub { return bless {}, "Cpanel::HTTP::Client::Response"; }, 'die_on_http_error' => sub { return $_[0]; } );
my $resp_mocker = Test::MockModule->new("Cpanel::HTTP::Client::Response");
$resp_mocker->mock( 'success' => sub { return 1; }, 'status' => sub { return 200; }, 'reason' => sub { return 'OK'; } );

isa_ok( my $spammer = Cpanel::iContact::Provider::Slack->new(), "Cpanel::iContact::Provider::Slack" );
is( exception { $spammer->send() }, undef, "send doesn't throw on GreatSuccess" );
my $redirect_mocker = Test::MockModule->new("Cpanel::Redirect");
$resp_mocker->mock( 'success' => sub { return 0; }, 'status' => sub { return 500; }, 'reason' => sub { return 'ENOHUGS'; } );
isnt( exception { $spammer->send() }, undef, "send throws whenever anything goes wrong" );
