install:
	install -m 0700 notification-center.pl /usr/local/cpanel/whostmgr/docroot/cgi/addon_notification-center.cgi
	install -m 0700 notification-center.tt /usr/local/cpanel/whostmgr/docroot/templates/addon_notification-center.tmpl
	install -m 0755 nfcenter.png /usr/local/cpanel/whostmgr/docroot/addon_plugins/nfcenter.png
	mkdir -p /var/cpanel/apps; /bin/true
	chmod 0755 /var/cpanel/apps
	/usr/local/cpanel/bin/register_appconfig notification-center.conf
uninstall:
	rm /usr/local/cpanel/whostmgr/docroot/cgi/addon_notification-center.cgi
	rm /usr/local/cpanel/whostmgr/docroot/templates/addon_notification-center.tmpl
	rm /var/cpanel/apps/notification-center.conf
	rm /usr/local/cpanel/whostmgr/docroot/addon_plugins/nfcenter.png
