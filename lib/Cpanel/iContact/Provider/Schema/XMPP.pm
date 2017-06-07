package Cpanel::iContact::Provider::Schema::XMPP;

use strict;
use warnings;

sub get_settings {
    my $help1 = <<HALP;
<p>The XMPP <em>users<em> you wish to send cPanel & WHM notifications <em>to</em>.<br />
For multiple addresses, delimit them with commas.<br />
Example: "cronspam&#64;dev.null,some_schmoe&#64;jabber.org"</p>
<p><strong>NOTE:</strong> Using a Gmail account may not work, as they deprecated XMPP in 2013.
See <a href="https://www.eff.org/deeplinks/2013/05/google-abandons-open-standards-instant-messaging">here</a>
for more details.</p> Similarly, your Jabber Server may need to tweak it's S2S connection settings,
as google talk has not supported SSL/TLS over server <-> server communications for
<a href="https://stackoverflow.com/questions/18713955/ejabberd-s2s-to-gtalk-hangout-with-tls">quite some time</a>.
HALP
    my $help2 = <<HALP;
<p>The XMPP <em>user<em> you wish to send cPanel & WHM notifications <em>from</em>.<br />
Example: "ali_baba&#64;thieves.den"</p>
<p><strong>NOTE:</strong> If the recipient is not registered on the same XMPP server as you,
you may need to contact the administrator of the server if sending to these users fail,
as this could indicate a problem with their s2s settings.
</p>
HALP
    my $help3 = <<HALP;
<p>The password for the user you wish to send cPanel & WHM notifications from.<br />
Example: "openSesame1"</p>
HALP
    my $help4 = <<HALP;
<p>Whether or not the XMPP server your Notification User is registered at supports TLS.<br />
If set improperly, this will cause sending notifications to fail.
</p>
HALP
    my $help5 = <<HALP;
<p>Whether or not the XMPP server your Notification User is registered at has a valid TLS Certificate.<br />
Setting this option to true will cause the notification to no longer fail if it encounters a self-signed certificate,
as an example.
</p>
HALP
    my $help6 = <<HALP;
<p>Use this setting to override the hostname your Notification User's XMPP to be whatever the server
<em>thinks</em> it actually is.<br />
This can be used to avoid 'unknown hostname' errors when dealing with misconfigured XMPP servers or SRV records.
</p>
HALP
    return {
        'CONTACTXMPP' => {
            'shadow'   => 1,
            'type'     => 'text',
            'checkval' => sub {
                my $value = shift;
                my @addrs = split( ",", $value );
                # Pick out bogus values
                require Email::Vaild;
                @addrs = grep { Email::Valid->address($_) } @addrs;
                return join( ",", @addrs );
            },
            'label' => 'XMPP Notification Destinations',
            'help' => $help1,
        },
        'XMPPUSERNAME' => {
            'shadow'   => 1,
            'type'     => 'text',
            'label' => 'XMPP Notification Account Username',
            'help' => $help2,
        },
        'XMPPPASSWORD' => {
            'shadow'   => 1,
            'type'     => 'password',
            'label' => 'XMPP Notification Account Password',
            'help' => $help3,
        },
        'XMPPUSETLS' => {
            'type'     => 'binary',
            'label' => 'XMPP: Use TLS?',
            'help' => $help4,
        },
        'XMPPVERIFYCERT' => {
            'type'     => 'binary',
            'label' => 'XMPP: Verify TLS Certificate?',
            'help' => $help5,
        },
        'XMPPCOMPONENTNAME' => {
            'type'     => 'text',
            'label' => 'XMPP Component Name',
            'help' => $help5,
        },
    };
}

sub get_config {
    my $svg = "%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20height%3D%22181.44%22%20viewBox%3D%220%200%20176.486%20181.437%22%20width%3D%22176.49%22%3E%3ClinearGradient%20id%3D%22a%22%20gradientUnits%3D%22userSpaceOnUse%22%20x2%3D%22-1807.2%22%20gradientTransform%3D%22translate%281916%29%22%20y1%3D%22125.86%22%20x1%3D%22-1807.2%22%3E%3Cstop%20stop-color%3D%22%231b3967%22%20offset%3D%22.011%22%2F%3E%3Cstop%20stop-color%3D%22%2313b5ea%22%20offset%3D%22.467%22%2F%3E%3Cstop%20stop-color%3D%22%23002b5c%22%20offset%3D%22.995%22%2F%3E%3C%2FlinearGradient%3E%3Cpath%20d%3D%22M136.29%2014.19c.077%201.312-1.786.967-1.786%202.292%200%2038.55-44.72%2096.83-89.847%20108.19v1.182c59.957-5.51%20126.73-66.8%20128.24-125.85l-36.6%2014.19z%22%20fill%3D%22url%28%23a%29%22%2F%3E%3Cpath%20d%3D%22M120.23%2017.96c.077%201.313.12%202.633.12%203.958%200%2038.55-30.7%2090.497-75.826%20101.86v1.637c59.065-3.823%20105.81-63.023%20105.81-109.2%200-2.375-.125-4.73-.37-7.056l-29.73%208.795z%22%20fill%3D%22%23E96D1F%22%2F%3E%3ClinearGradient%20id%3D%22b%22%20gradientUnits%3D%22userSpaceOnUse%22%20x2%3D%22-1073.2%22%20gradientTransform%3D%22matrix%28-1%200%200%201%20-1008.2%200%29%22%20y1%3D%22126.85%22%20x1%3D%22-1073.2%22%3E%3Cstop%20stop-color%3D%22%231b3967%22%20offset%3D%22.011%22%2F%3E%3Cstop%20stop-color%3D%22%2313b5ea%22%20offset%3D%22.467%22%2F%3E%3Cstop%20stop-color%3D%22%23002b5c%22%20offset%3D%22.995%22%2F%3E%3C%2FlinearGradient%3E%3Cpath%20d%3D%22M36.6%2014.19c-.078%201.312%201.786.967%201.786%202.292%200%2038.55%2046.558%2097.366%2091.688%20108.73v1.64C70.12%20121.33%201.514%2059.05.004%200l36.6%2014.188z%22%20fill%3D%22url%28%23b%29%22%2F%3E%3Cpath%20d%3D%22M54.73%2018.932c-.075%201.313-.12%202.63-.12%203.957%200%2038.55%2030.7%2090.496%2075.828%20101.86v1.638c-59.044-2.79-105.81-63.024-105.81-109.2%200-2.375.128-4.73.37-7.056l29.73%208.798z%22%20fill%3D%22%23A0CE67%22%2F%3E%3Cpath%20d%3D%22M24.713%209.583l7.617%202.722c-.04.962-.066%202.254-.066%203.225%200%2041.22%2037.27%2098.204%2087.272%20107.12%203.245%201.088%207.538%202.077%2010.932%202.93v1.64c-65.254-5.56-111.1-71.867-105.76-117.64z%22%20fill%3D%22%23439639%22%2F%3E%3Cpath%20d%3D%22M150.34%208.76l-7.833%202.625c.04.963.19%202.203.19%203.173%200%2041.22-37.27%2098.205-87.273%20107.12-3.243%201.09-7.538%202.077-10.93%202.932v1.64c68.344-8.66%20111.18-71.72%20105.84-117.49z%22%20fill%3D%22%23D9541E%22%2F%3E%3Cpath%20d%3D%22M14.576%20166.71L1.188%20152.06H12.83l9.128%2010.268%209.13-10.268H42.73l-13.387%2014.646%2014.4%2014.728h-12.09l-9.696-10.67-9.693%2010.67H.172l14.404-14.73zM47.096%20152.06h13.836l10.183%2018.905%2010.183-18.905H95.13v29.374h-8.762v-21.096h-.08L74.48%20181.434H67.75L55.94%20160.338h-.08v21.096h-8.765v-29.37zM101.25%20152.06h24.546c8.56%200%2010.628%204.302%2010.628%2010.063v2.516c0%204.38-1.908%209.41-8.275%209.41h-17.895v7.384h-9.005v-29.38zm9%2014.69h13.997c2.11%200%202.924-1.377%202.924-3.123v-1.135c0-1.99-.975-3.127-3.693-3.127H110.25v7.38zM141.31%20152.06h24.546c8.56%200%2010.63%204.302%2010.63%2010.063v2.516c0%204.38-1.907%209.41-8.275%209.41H150.32v7.384h-9.008v-29.38zm9.01%2014.69h13.996c2.11%200%202.922-1.377%202.922-3.123v-1.135c0-1.99-.974-3.127-3.693-3.127H150.32v7.38z%22%2F%3E%3C%2Fsvg%3E";
    return {
        'default_level'    => 'All',
        'display_name'     => 'XMPP',
        'icon_name'        => 'XMPP',
        'icon'             => "data:image/svg+xml,$svg",
    };
}

1;
