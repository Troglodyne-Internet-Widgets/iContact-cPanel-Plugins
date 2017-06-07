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
    my $b64 = "PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMTgxLjQ0IiB2aWV3Qm94PSIwIDAgMTc2LjQ4NiAxODEuNDM3IiB3aWR0aD0iMTc2LjQ5Ij48bGluZWFyR3JhZGllbnQgaWQ9ImEiIGdyYWRpZW50VW5pdHM9InVzZXJTcGFjZU9uVXNlIiB4Mj0iLTE4MDcuMiIgZ3JhZGllbnRUcmFuc2Zvcm09InRyYW5zbGF0ZSgxOTE2KSIgeTE9IjEyNS44NiIgeDE9Ii0xODA3LjIiPjxzdG9wIHN0b3AtY29sb3I9IiMxYjM5NjciIG9mZnNldD0iLjAxMSIvPjxzdG9wIHN0b3AtY29sb3I9IiMxM2I1ZWEiIG9mZnNldD0iLjQ2NyIvPjxzdG9wIHN0b3AtY29sb3I9IiMwMDJiNWMiIG9mZnNldD0iLjk5NSIvPjwvbGluZWFyR3JhZGllbnQ+PHBhdGggZD0iTTEzNi4yOSAxNC4xOWMuMDc3IDEuMzEyLTEuNzg2Ljk2Ny0xLjc4NiAyLjI5MiAwIDM4LjU1LTQ0LjcyIDk2LjgzLTg5Ljg0NyAxMDguMTl2MS4xODJjNTkuOTU3LTUuNTEgMTI2LjczLTY2LjggMTI4LjI0LTEyNS44NWwtMzYuNiAxNC4xOXoiIGZpbGw9InVybCgjYSkiLz48cGF0aCBkPSJNMTIwLjIzIDE3Ljk2Yy4wNzcgMS4zMTMuMTIgMi42MzMuMTIgMy45NTggMCAzOC41NS0zMC43IDkwLjQ5Ny03NS44MjYgMTAxLjg2djEuNjM3YzU5LjA2NS0zLjgyMyAxMDUuODEtNjMuMDIzIDEwNS44MS0xMDkuMiAwLTIuMzc1LS4xMjUtNC43My0uMzctNy4wNTZsLTI5LjczIDguNzk1eiIgZmlsbD0iI0U5NkQxRiIvPjxsaW5lYXJHcmFkaWVudCBpZD0iYiIgZ3JhZGllbnRVbml0cz0idXNlclNwYWNlT25Vc2UiIHgyPSItMTA3My4yIiBncmFkaWVudFRyYW5zZm9ybT0ibWF0cml4KC0xIDAgMCAxIC0xMDA4LjIgMCkiIHkxPSIxMjYuODUiIHgxPSItMTA3My4yIj48c3RvcCBzdG9wLWNvbG9yPSIjMWIzOTY3IiBvZmZzZXQ9Ii4wMTEiLz48c3RvcCBzdG9wLWNvbG9yPSIjMTNiNWVhIiBvZmZzZXQ9Ii40NjciLz48c3RvcCBzdG9wLWNvbG9yPSIjMDAyYjVjIiBvZmZzZXQ9Ii45OTUiLz48L2xpbmVhckdyYWRpZW50PjxwYXRoIGQ9Ik0zNi42IDE0LjE5Yy0uMDc4IDEuMzEyIDEuNzg2Ljk2NyAxLjc4NiAyLjI5MiAwIDM4LjU1IDQ2LjU1OCA5Ny4zNjYgOTEuNjg4IDEwOC43M3YxLjY0QzcwLjEyIDEyMS4zMyAxLjUxNCA1OS4wNS4wMDQgMGwzNi42IDE0LjE4OHoiIGZpbGw9InVybCgjYikiLz48cGF0aCBkPSJNNTQuNzMgMTguOTMyYy0uMDc1IDEuMzEzLS4xMiAyLjYzLS4xMiAzLjk1NyAwIDM4LjU1IDMwLjcgOTAuNDk2IDc1LjgyOCAxMDEuODZ2MS42MzhjLTU5LjA0NC0yLjc5LTEwNS44MS02My4wMjQtMTA1LjgxLTEwOS4yIDAtMi4zNzUuMTI4LTQuNzMuMzctNy4wNTZsMjkuNzMgOC43OTh6IiBmaWxsPSIjQTBDRTY3Ii8+PHBhdGggZD0iTTI0LjcxMyA5LjU4M2w3LjYxNyAyLjcyMmMtLjA0Ljk2Mi0uMDY2IDIuMjU0LS4wNjYgMy4yMjUgMCA0MS4yMiAzNy4yNyA5OC4yMDQgODcuMjcyIDEwNy4xMiAzLjI0NSAxLjA4OCA3LjUzOCAyLjA3NyAxMC45MzIgMi45M3YxLjY0Yy02NS4yNTQtNS41Ni0xMTEuMS03MS44NjctMTA1Ljc2LTExNy42NHoiIGZpbGw9IiM0Mzk2MzkiLz48cGF0aCBkPSJNMTUwLjM0IDguNzZsLTcuODMzIDIuNjI1Yy4wNC45NjMuMTkgMi4yMDMuMTkgMy4xNzMgMCA0MS4yMi0zNy4yNyA5OC4yMDUtODcuMjczIDEwNy4xMi0zLjI0MyAxLjA5LTcuNTM4IDIuMDc3LTEwLjkzIDIuOTMydjEuNjRjNjguMzQ0LTguNjYgMTExLjE4LTcxLjcyIDEwNS44NC0xMTcuNDl6IiBmaWxsPSIjRDk1NDFFIi8+PHBhdGggZD0iTTE0LjU3NiAxNjYuNzFMMS4xODggMTUyLjA2SDEyLjgzbDkuMTI4IDEwLjI2OCA5LjEzLTEwLjI2OEg0Mi43M2wtMTMuMzg3IDE0LjY0NiAxNC40IDE0LjcyOGgtMTIuMDlsLTkuNjk2LTEwLjY3LTkuNjkzIDEwLjY3SC4xNzJsMTQuNDA0LTE0Ljczek00Ny4wOTYgMTUyLjA2aDEzLjgzNmwxMC4xODMgMTguOTA1IDEwLjE4My0xOC45MDVIOTUuMTN2MjkuMzc0aC04Ljc2MnYtMjEuMDk2aC0uMDhMNzQuNDggMTgxLjQzNEg2Ny43NUw1NS45NCAxNjAuMzM4aC0uMDh2MjEuMDk2aC04Ljc2NXYtMjkuMzd6TTEwMS4yNSAxNTIuMDZoMjQuNTQ2YzguNTYgMCAxMC42MjggNC4zMDIgMTAuNjI4IDEwLjA2M3YyLjUxNmMwIDQuMzgtMS45MDggOS40MS04LjI3NSA5LjQxaC0xNy44OTV2Ny4zODRoLTkuMDA1di0yOS4zOHptOSAxNC42OWgxMy45OTdjMi4xMSAwIDIuOTI0LTEuMzc3IDIuOTI0LTMuMTIzdi0xLjEzNWMwLTEuOTktLjk3NS0zLjEyNy0zLjY5My0zLjEyN0gxMTAuMjV2Ny4zOHpNMTQxLjMxIDE1Mi4wNmgyNC41NDZjOC41NiAwIDEwLjYzIDQuMzAyIDEwLjYzIDEwLjA2M3YyLjUxNmMwIDQuMzgtMS45MDcgOS40MS04LjI3NSA5LjQxSDE1MC4zMnY3LjM4NGgtOS4wMDh2LTI5LjM4em05LjAxIDE0LjY5aDEzLjk5NmMyLjExIDAgMi45MjItMS4zNzcgMi45MjItMy4xMjN2LTEuMTM1YzAtMS45OS0uOTc0LTMuMTI3LTMuNjkzLTMuMTI3SDE1MC4zMnY3LjM4eiIvPjwvc3ZnPg==";
    return {
        'default_level'    => 'All',
        'display_name'     => 'XMPP',
        'icon_name'        => 'XMPP',
        'icon'             => "data:image/png;base64,$b64",
    };
}

1;
