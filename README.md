# iContact-cPanel-Plugins
Extra "Contact Manager" Providers for cPanel and WHM

Current plugins:
================
* XMPP  -- Stable XMPP provider (well, as stable as Net::XMPP is, anyways). See issue #2
* IRC   -- Still WIP, don't use this, as it is completely untested and currently no-op on send.
* Slack -- Works presuming you have an incoming WebHook URL, much like CpanelRicky's MatterMost plugin.

Installation and Use:
---------------------
* Clone this repo with git onto a cPanel host of at least 11.64+
* Run the Tests

    make test

* Install the Modules

    make install

* Go to WHM >> Basic Setup and configure the provider options
* Go to WHM >> Contact Manager and make sure it is set up to spam you mercilessly
* Do something to trigger notifications from cPanel & WHM

KNOWN BUGS
----------
* ejabberd:
Currently, the DIGEST-MD5 method (used by default in Net::XMPP when authenticating against the latest ejabberd versions)
causes failures to send notifications. Add `disable_sasl_mechanisms: "DIGEST-MD5"` to your `ejabberd.yml` config file
to avoid this problem. See issue #2 on the tracker.

TESTING NOTES
-------------
If you want to run a functional test of the XMPP iContact code in order to debug problems, set the env var `AUTHOR_TESTS`
and write out .xmpptestrc in the toplevel directory of this git repository with content like:

`XMPPUSERNAME: user@domain.tld`

`XMPPPASSWORD: hunter2`

`XMPPCOMPONENTNAME:`

`XMPPUSETLS: 1`

`XMPPVERIFYCERT: 0`

You'll note these correspond to the values in the Provider's Schema module. With that set, you should spam yourself with
a message if the t/Cpanel-iContact-Provider-XMPP.t test passes.
