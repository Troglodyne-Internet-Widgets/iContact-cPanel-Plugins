# ================================
# MOCK ME BABY ALL NIGHT LONG
# ================================
package Cpanel::iContact::Provider;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $text_body = 'HOLY CRAP THE AUTO-LAYOFF THING TRIGGERED';
    my $html_body = "<p>$text_body</p>";
    my $self = {
        'contact' => {
            'XMPPUSERNAME'      => 'mr_t@a-team.gov',
            'XMPPPASSWORD'      => 'bjBarracus#1',
            'XMPPUSETLS'        => 1,
            'XMPPTLSVERIFY'     => 1,
            'XMPPCOMPONENTNAME' => 'jibber.jabber.org',
            'IRCSERVER'         => 'irc.bot.test',
            'IRCPORT'           => 666,
            'IRCNICK'           => 'DevilBot',
        },
        'args' => {
            'subject'   => 'cPanel on Drugs',
            'text_body' => \$text_body, #nutty, I know
            'html_body' => \$html_body,
            'to'        => [ 'cronspam@dev.null' ],
        }
    };
    return bless $self, $class;
}

1;
