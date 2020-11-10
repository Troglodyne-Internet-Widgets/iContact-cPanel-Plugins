# iContact-cPanel-Plugins
Extra "Contact Manager" Providers for cPanel and WHM

Current plugins:
================
* XMPP  -- Stable XMPP provider (well, as stable as Net::XMPP is, anyways). See issue #2
* IRC   -- New provider, needs more testing by users out in the wild. "Works for Me"
* Slack -- Works presuming you have an incoming WebHook URL, much like CpanelRicky's MatterMost plugin.
* Discord -- Similar to Slack, use an incoming WebHook URL.
* Telegram -- Works, though getting the right numeric ID for the user/group you want to message may be tricky. An instructional video has been posted [here](https://www.youtube.com/watch?v=vnCFlu2KzhI&feature=youtu.be) to assist you with getting this all setup.

If you like this plugin, consider sending a a few dollars this way:
https://paypal.me/troglodyne

Installation and Use:
---------------------
* Clone this repo with git onto a cPanel host of at least 11.64+.
* After changing the current working directory of your terminal session into the repo's directory, run `make` if you want to install all the providers.

OR

* If you want to only install one specific provider, run 'make install-$provider' -- example: `make install-slack` would install Slack's provider.
* (Optionally) Run the Tests with `make test`
* Go to WHM >> Basic Setup and configure the provider options
* Go to WHM >> Contact Manager and make sure it is set up to spam you mercilessly (and for the notifications you care about!).
* Do something to trigger a notification that should fire notifications from cPanel & WHM per your preference in /etc/clevels.conf
* If you tire of the modules and want to get rid of them, run `make uninstall`.

KNOWN BUGS
----------
*ejabberd:*

Currently, the DIGEST-MD5 method (used by default in Net::XMPP when authenticating against the latest ejabberd versions)
causes failures to send notifications. Add `disable_sasl_mechanisms: "DIGEST-MD5"` to your `ejabberd.yml` config file
to avoid this problem. See issue #2 on the tracker.

*XMPP Driver (generally):*

I've seen a report about gtalk.t failing on install for certain users when attempting to install Net::XMPP as a dependency.
If this occurs, you'll likely have to manually run CPAN and tell it to ignore the failing tests:
`cpan -i -f Net::XMPP`. After it installs you can then rerun make install and it should be OK. (the '-f' flag stands for 'force')

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

CONTACT
-------
As always, if you feel there's a bug, please file an issue on the tracker.
If you want to chat, hit up _teodesian_ on the [teodesian Discord Server](https://discord.gg/4tMXEWXs47).
