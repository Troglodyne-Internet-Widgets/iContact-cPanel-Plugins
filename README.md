# iContact-cPanel-Plugins
Extra "Contact Manager" Providers for cPanel and WHM

Still somewhat WIP, for now only has 'alpha' quality XMPP provider
Plans for the future in TODO

Steps 4 GreatSuccess:
* Clone this repo with git onto a cPanel host of at least 11.62+
* Run the Tests

    make test

* Install the Modules

    make install

* Go to WHM >> Basic Setup and configure the provider options
* Go to WHM >> Contact Manager and make sure it is set up to spam you mercilessly
* Do something to trigger notifications from cPanel & WHM

Enjoy!
