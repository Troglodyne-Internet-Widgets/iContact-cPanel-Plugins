# iContact-cPanel-Plugins
Extra "Contact Manager" Providers for cPanel and WHM

Current plugins:
================
* XMPP  -- Stable XMPP provider (well, as stable as Net::XMPP is, anyways). See issue #2
* IRC   -- New provider, needs more testing by users out in the wild. "Works for Me"
* Slack -- Works presuming you have an incoming WebHook URL, much like CpanelRicky's MatterMost plugin.
* Discord -- Similar to Slack, use an incoming WebHook URL.

Installation and Use:
---------------------
* Clone this repo with git onto a cPanel host of at least 11.64+, then run `make` after changing the current working directory of your terminal session into the repo's directory.
* (Optionally) Run the Tests with `make test`
* Go to WHM >> Basic Setup and configure the provider options
* Go to WHM >> Contact Manager and make sure it is set up to spam you mercilessly (and for the notifications you care about!).
* Do something to trigger a notification that should fire notifications from cPanel & WHM per your preference in /etc/clevels.conf

KNOWN BUGS
----------
* ejabberd:
Currently, the DIGEST-MD5 method (used by default in Net::XMPP when authenticating against the latest ejabberd versions)
causes failures to send notifications. Add `disable_sasl_mechanisms: "DIGEST-MD5"` to your `ejabberd.yml` config file
to avoid this problem. See issue #2 on the tracker.

TESTING NOTES
-------------
If you want to run a functional test for any of these (to debug problems), please run the following script:
`scripts/generate_testing_configuration.pl`
as this will prompt you for all the needed values to make the test run (it tells you how to run it too).

Anyways, this script will write out a file like the following to the repo's top level directory.
In this example, we're using the XMPP provider, so it will be .xmpptestrc:

`XMPPUSERNAME: user@domain.tld`

`XMPPPASSWORD: hunter2`

`XMPPCOMPONENTNAME:`

`XMPPUSETLS: 1`

`XMPPVERIFYCERT: 0`

You'll note these correspond to the values in the Provider's Schema module. With that set, you should spam yourself with
a message if the t/Cpanel-iContact-Provider-XMPP.t test passes.

Same goes for the IRC or Slack provider... use the same keys as in the schema module for dopeouts in its' test.
