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
use Cpanel::iContact::Provider::Telegram ();

plan tests => 2;

# First, let's mock out the parent, and other stuff we wouldn't wanna do in a unit test
subtest "Provider bits work as expected ('unit' test)" => sub {
    my $text_scalar = 'lol, jk';
    my $send_args   = { 'subject' => "[test.host.tld] YOUR COMIC BOOKS ARE DYING!!!1", 'text_body' => \$text_scalar, 'to' => [ 'SalinasPunishmentRoom', '@cPSaurus' ] };
    my $contact_cfg = { 'TELEGRAMBOTTOKEN' => '420SWAGYOLO69696969' };
    my $ua_mocker = Test::MockModule->new("WWW::Telegram::BotAPI");

    # Mock has to be used instead of redefine due to AUTOLOAD
    $ua_mocker->mock( 'getMe' => sub {}, 'sendMessage' => sub {} );

    isa_ok( my $spammer = Cpanel::iContact::Provider::Telegram->new(), "Cpanel::iContact::Provider::Telegram" );
    $spammer->{'contact'} = $contact_cfg;
    is( exception { $spammer->send() }, undef, "send doesn't throw on GreatSuccess" );
    $ua_mocker->mock( 'getMe' => sub { die "401 Unauthorized" } );
    isnt( exception { $spammer->send() }, undef, "send throws whenever anything goes wrong" );
};

subtest "Can send a message to somewhere (systems level/integration test)" => sub {
    SKIP: {
        my $conf_file = abs_path( dirname(__FILE__) . "/../.telegramtestrc" );
        skip "Skipping functional testing, needful not supplied", 1 if !$ENV{'AUTHOR_TESTS'} || !-f $conf_file;
        my $test_conf = Config::Simple->import_from($conf_file);
        my $text_body = "This is a test of Cpanel::iContact::Provider::Telegram. Please Ignore";
        my %args = (
            'to'        => [ $test_conf->param('CONTACTTELEGRAM') ],
            'subject'   => 'My Super cool test notification',
            'text_body' => \$text_body,
        );

        {
            no warnings qw{redefine once};
            local *Cpanel::iContact::Provider::Telegram::new = sub {
                return bless {
                    'contact' => { 'TELEGRAMBOTTOKEN' => $test_conf->param('TELEGRAMBOTTOKEN') },
                    'args'    => \%args,
                }, $_[0];
            };
            my $spammer = Cpanel::iContact::Provider::Telegram->new();
            my $ex;
            is( $ex = exception { $spammer->send() }, undef, "Didn't fail to send notification using full functional test" ) || diag explain $ex;
        }
    }
};
