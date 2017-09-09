use strict;
use warnings;

use Cwd qw{abs_path};
use File::Basename qw{dirname};
use lib abs_path( dirname(__FILE__) . "/../lib" );

use Test::More 'tests' => 5;
use Test::Fatal;
use Config::Simple ();

is( exception { require Cpanel::iContact::Provider::XMPP; }, undef, 'Module at least compiles' );
isa_ok( my $xmpp = Cpanel::iContact::Provider::XMPP->new(), "Cpanel::iContact::Provider::XMPP" );
my $sent;
{
    no warnings qw{redefine once};
    local *Net::XMPP::Client::Connect     = sub { return 1; };
    local *Net::XMPP::Client::AuthSend    = sub { return ( 'ok', "Assumed Success" ); };
    local *Net::XMPP::Client::MessageSend = sub { return; };
    local *Net::XMPP::Client::Disconnect  = sub { return; };
    is( exception { $sent = $xmpp->send(); }, undef, 'send() did not die' );
}
ok( $sent, "...and the message appears to have actually sent." );

SKIP: {
    my $conf_file = abs_path( dirname(__FILE__) . "/../.xmpptestrc" );
    diag("Conf file '$conf_file' doesn't exist") if !-f $conf_file;
    skip "Skipping functional testing, needful not supplied", 1 if !$ENV{'AUTHOR_TESTS'} || !-f $conf_file;
    my $test_conf = { Config::Simple->import_from($conf_file)->vars() };
    my %args = (
        'destination' => $test_conf->{'XMPPUSERNAME'},
        'subject' => 'My Super cool test notification',
        'content' => "This is a test of Cpanel::iContact::Provider::XMPP. Please Ignore",
    );

    {
        no warnings qw{redefine once};
        local *Cpanel::iContact::Provider::XMPP::new = sub {
            return bless {
                'contact' => $test_conf,
            }, $_[0];
        };
        my $spammer = Cpanel::iContact::Provider::XMPP->new();
        is( exception { $spammer->_send(%args) }, undef, "Didn't fail to send notification using full functional test" );
    }
}

# TODO error paths
#isnt( exception { $xmpp->send(); }, undef, "We blew up when we timed out on connect" );
