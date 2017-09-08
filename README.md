# iContact-cPanel-Plugins
Extra "Contact Manager" Providers for cPanel and WHM

Current plugins:
================
* XMPP  -- Stable XMPP provider (as I've received no external bug reports and it has worked well for me for over a month)
* IRC   -- Still WIP, completely untested.
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
