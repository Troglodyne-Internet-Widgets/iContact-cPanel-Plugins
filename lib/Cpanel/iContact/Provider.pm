# ================================
# MOCK ME BABY ALL NIGHT LONG
# ================================
package Cpanel::iContact::Provider;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $text_body = 'HOLY CRAP THE AUTO-LAYOFF THING TRIGGERED';
    my $self = {
        'contact' => {
            'XMPPUSERNAME'  => 'mr_t@a-team.gov',
            'XMPPPASSWORD'  => 'bjBarracus#1',
            'XMPPUSETLS'    => 1,
            'XMPPTLSVERIFY' => 1,
            'XMPPCOMPONENTNAME' => 'jibber.jabber.org'
        },
        'args' => {
            'subject'   => 'cPanel on Drugs',
            'text_body' => \$text_body, #nutty, I know
            'to'        => [ 'cronspam@dev.null' ],
        }
    };
    return bless $self, $class;
}

1;
