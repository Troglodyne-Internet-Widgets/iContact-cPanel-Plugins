use strict;
use warnings;

use Cwd qw{abs_path};
use File::Basename qw{dirname};
use lib abs_path( dirname(__FILE__) . "/../lib" );

use Test::More;
use Test::Fatal;
use Test::MockModule ();
use Config::Simple   ();

use Cpanel::HTTP::Client              ();
use Cpanel::HTTP::Client::Response    ();
use Cpanel::iContact::Provider::Slack ();

plan tests => 2;

# First, let's mock out the parent, and other stuff we wouldn't wanna do in a unit test
subtest "Provider bits work as expected ('unit' test)" => sub {
    my $text_scalar = 'lol, jk';
    my $send_args   = { 'subject' => "[test.host.tld] YOUR COMIC BOOKS ARE DYING!!!1", 'text_body' => \$text_scalar, 'to' => [ 'SalinasPunishmentRoom', '@cPSaurus' ] };
    my $contact_cfg = {};
    my $ua_mocker = Test::MockModule->new("Cpanel::HTTP::Client");
    $ua_mocker->mock( 'request' => sub { return bless {}, "Cpanel::HTTP::Client::Response"; } );
    my $resp_mocker = Test::MockModule->new("Cpanel::HTTP::Client::Response");
    $resp_mocker->mock( 'success' => sub { return 1; }, 'status' => sub { return 200; }, 'reason' => sub { return 'OK'; } );

    isa_ok( my $spammer = Cpanel::iContact::Provider::Slack->new(), "Cpanel::iContact::Provider::Slack" );
    is( exception { $spammer->send() }, undef, "send doesn't throw on GreatSuccess" );
    $resp_mocker->mock( 'success' => sub { return 0; }, 'status' => sub { return 500; }, 'reason' => sub { return 'ENOHUGS'; } );
    isnt( exception { $spammer->send() }, undef, "send throws whenever anything goes wrong" );
};

subtest "Can send a message to somewhere (systems level/integration test)" => sub {
    my $conf_file = abs_path( dirname(__FILE__) . "/../.slacktestrc" );
    skip "Skipping functional testing, needful not supplied", 1 if !$ENV{'AUTHOR_TESTS'} || !-f $conf_file;
    my $test_conf = { Config::Simple->import_from($conf_file)->vars() };
    my $text_body = "This is a test of Cpanel::iContact::Provider::Slack. Please Ignore";
    my %args = (
        'to'        => [ $test_conf->{'CONTACTSLACK'} ],
        'subject'   => 'My Super cool test notification',
        'text_body' => \$text_body,
    );

    {
        no warnings qw{redefine once};
        local *Cpanel::iContact::Provider::Slack::new = sub {
            return bless {
                'contact' => $test_conf,
                'args'    => \%args,
            }, $_[0];
        };
        my $spammer = Cpanel::iContact::Provider::Slack->new();
        is( exception { $spammer->send() }, undef, "Didn't fail to send notification using full functional test" );
    }
};
