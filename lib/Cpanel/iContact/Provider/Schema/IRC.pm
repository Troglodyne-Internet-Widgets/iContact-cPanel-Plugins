package Cpanel::iContact::Provider::Schema::IRC;

use strict;
use warnings;

sub get_settings {
    my $help1 = <<HALP;
<p>The IRC <em>channels</em> you wish to send cPanel & WHM notifications <em>to</em>.<br />
For multiple channels, delimit them with commas.<br />
Example: "#YOLO,#swag"</p>
HALP
    my $help2 = <<HALP;
<p>The IRC <em>nickname</em> you wish for cPanel & WHM notifications to use.<br />
Example: "cPSaurus"</p>
HALP
    my $help3 =<<HALP;
<p>Whether or not the IRC server your Notification User is registered at supports SSL/TLS.<br />
If set improperly, this will cause sending notifications to fail (some IRC servers <em>require</em> SSL/TLS, some <em>don't support it</em>).
</p>
HALP
    my $help4 =<<HALP;
<p>The IRC Server Address<br />
The domain or IP your IRC server is active on.
</p>
HALP
    my $help5 =<<HALP;
<p>The IRC Server Port<br />
The port your IRC server is active on. Defaults to 6667.
</p>
HALP
    return {
        'CONTACTIRC' => {
            'shadow'   => 1,
            'type'     => 'text',
            'checkval' => sub {
                my $value = shift;
                my @chans = split( ",", $value );
                @chans = grep { index( $_, '#' ) != -1 } @chans;
                return join( ",", @chans );
            },
            'label' => 'IRC Notification Destinations'
            'help' => $help1,
        },
        'IRCNICK' => {
            'shadow'   => 1,
            'type'     => 'text',
            'label' => 'IRC Notification Bot Nickname',
            'help' => $help2,
        },
        'IRCUSESSL' => {
            'type'     => 'binary',
            'label' => 'IRC: Use SSL/TLS?',
            'help' => $help3,
        },
        'IRCSERVER' => {
            'type'     => 'binary',
            'label' => 'IRC Server Address',
            'help' => $help3,
        },
       'IRCPORT' => {
            'type'     => 'binary',
            'label' => 'IRC Server Port',
            'help' => $help3,
        },

    };
}

sub get_config {
    my $svg = "%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%2048%2048%22%3E%3Cdefs%3E%3ClinearGradient%20gradientUnits%3D%22userSpaceOnUse%22%20x2%3D%2247%22%20x1%3D%220%22%3E%3Cstop%20stop-color%3D%22%23a9a3d4%22%2F%3E%3Cstop%20offset%3D%22.47%22%20stop-color%3D%22%2387baff%22%2F%3E%3Cstop%20offset%3D%221%22%20stop-color%3D%22%2389ec85%22%2F%3E%3C%2FlinearGradient%3E%3ClinearGradient%20id%3D%220%22%20y1%3D%22556.24%22%20x2%3D%220%22%20y2%3D%22510.24%22%20gradientUnits%3D%22userSpaceOnUse%22%3E%3Cstop%20stop-color%3D%22%232e5378%22%2F%3E%3Cstop%20offset%3D%221%22%20stop-color%3D%22%23387898%22%2F%3E%3C%2FlinearGradient%3E%3ClinearGradient%20id%3D%221%22%20x1%3D%22421.9%22%20y1%3D%22540.44%22%20x2%3D%22422.52%22%20y2%3D%22522.5%22%20gradientUnits%3D%22userSpaceOnUse%22%3E%3Cstop%20stop-color%3D%22%231584d8%22%2F%3E%3Cstop%20offset%3D%221%22%20stop-color%3D%22%231cb2ff%22%2F%3E%3C%2FlinearGradient%3E%3C%2Fdefs%3E%3Cg%20transform%3D%22matrix%281.04866%200%200%201.04866-511.61-528.36%29%22%20stroke-width%3D%221.317%22%3E%3Crect%20y%3D%22510.24%22%20x%3D%22296.96%22%20height%3D%2246%22%20width%3D%2246%22%20fill%3D%22url%28%230%29%22%20rx%3D%2223%22%20stroke-width%3D%222.164%22%20transform%3D%22matrix%28.99507%200%200%20.99507%20192.37-3.883%29%22%2F%3E%3Cpath%20d%3D%22m423.44%20523.59l-1.172%204.7h3.223l1.184-4.7h2.698l-1.184%204.7h3.381v2.6h-4.03l-.842%203.345h3.467v2.625h-4.102l-1.172%204.675h-2.698l1.172-4.675h-3.223l-1.172%204.675h-2.722l1.172-4.675h-3.406v-2.625h4l.854-3.345h-3.455v-2.6h4.126l1.172-4.7h2.722m1.379%207.3h-3.223l-.854%203.345h3.223l.854-3.345%22%20fill%3D%22%23fff%22%20fill-opacity%3D%22.85%22%20transform%3D%22matrix%281.33747%200%200%201.33747-54.714-185.56%29%22%2F%3E%3C%2Fg%3E%3C%2Fsvg%3E";
    return {
        'default_level'    => 'All',
        'display_name'     => 'IRC',
        'icon_name'        => 'IRC',
        'icon'             => "data:image/svg+xml,$svg",
    };
}

1;
