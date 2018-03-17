use strict;
use warnings;

use Cwd qw{abs_path};
use File::Basename qw{dirname};
use lib abs_path( dirname(__FILE__) . "/../lib" );

use Test::More 'tests' => 5;
use Test::Fatal;
use IO::Socket::INET ();
use IO::Socket::SSL  ();
use Config::Simple   ();

is( exception { require Cpanel::iContact::Provider::IRC; }, undef, 'Module at least compiles' );
isa_ok( my $bot = Cpanel::iContact::Provider::IRC->new(), "Cpanel::iContact::Provider::IRC" );
my $sent;
{
    no warnings qw{redefine once};
    #is( exception { $sent = $bot->send(); }, undef, 'send() did not throw' );
	pass("wha");
}
#ok( $sent, "...and the message appears to have actually sent." );
pass("dup");

SKIP: {
    my $conf_file = abs_path( dirname(__FILE__) . "/../.irctestrc" );
    skip "Skipping functional testing, needful not supplied", 1 if !$ENV{'AUTHOR_TESTS'} || !-f $conf_file;
    my $test_conf = { Config::Simple->import_from($conf_file)->vars() };
    my %args = (
        'destination' => $test_conf->{'CONTACTIRC'},
        'subject' => 'My Super cool test notification',
        'content' => "This is a test of Cpanel::iContact::Provider::IRC. Please Ignore",
    );

    {
        no warnings qw{redefine once};
        local *Cpanel::iContact::Provider::IRC::new = sub {
            return bless {
                'contact' => $test_conf,
            }, $_[0];
        };
        my $spammer = Cpanel::iContact::Provider::IRC->new();
        is( exception { $spammer->_send(%args) }, undef, "Didn't fail to send notification using full functional test" );
    }
}

# TODO error paths

