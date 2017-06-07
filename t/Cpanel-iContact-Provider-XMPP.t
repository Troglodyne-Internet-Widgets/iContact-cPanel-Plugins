use strict;
use warnings;

use Test::More 'tests' => 5;
use Test::Fatal;

# ================================
# MOCK ME BABY ALL NIGHT LONG
# ================================
package Cpanel::iContact::Provider;

sub new {
    my $class = shift;
    my $self = {
        'widdly' => 'waa',
    };
    return bless $self, $class;
}

is( exception { require Cpanel::iContact::Provider; }, undef, 'Module at least compiles' );
isa_ok( my $xmpp = Cpanel::iContact::Provider::XMPP->new(), "Cpanel::iContact::Provider::XMPP" );
my $sent;
{
    no warnings qw{redefine once};
    *Net::XMPP::Client::Connect     = sub { return 1; };
    *Net::XMPP::Client::AuthSend    = sub { return ( 'ok', "Assumed Success" ); };
    *Net::XMPP::Client::MessageSend = sub { return; };
    *Net::XMPP::Client::Disconnect  = sub { return; };
    is( exception { $sent = $xmpp->send(); }, undef, 'send() did not die' );
}
ok( $sent, "...and the message appears to have actually sent." );

# TODO more error paths
#isnt( exception { $xmpp->send(); }, undef, "We blew up when we timed out on connect" );
