all: install

install-dir:
	[ -d /var/cpanel/perl/Cpanel/iContact/Provider/Schema ] || mkdir -p /var/cpanel/perl/Cpanel/iContact/Provider/Schema/

install: depend-all install-dir
	cp -f lib/Cpanel/iContact/Provider/Schema/*.pm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/
	cp -f lib/Cpanel/iContact/Provider/*.pm /var/cpanel/perl/Cpanel/iContact/Provider/

install-slack: install-dir
	cp -f lib/Cpanel/iContact/Provider/Schema/Slack.pm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/Slack.pm
	cp -f lib/Cpanel/iContact/Provider/Slack.pm /var/cpanel/perl/Cpanel/iContact/Provider/Slack.pm

install-xmpp: depend-xmpp install-dir
	cp -f lib/Cpanel/iContact/Provider/Schema/XMPP.pm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/XMPP.pm
	cp -f lib/Cpanel/iContact/Provider/XMPP.pm /var/cpanel/perl/Cpanel/iContact/Provider/XMPP.pm

install-irc: depend-irc install-dir
	cp -f lib/Cpanel/iContact/Provider/Schema/IRC.pm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/IRC.pm
	cp -f lib/Cpanel/iContact/Provider/IRC.pm /var/cpanel/perl/Cpanel/iContact/Provider/IRC.pm

install-discord: install-dir
	cp -f lib/Cpanel/iContact/Provider/Schema/Discord.pm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/Discord.pm
	cp -f lib/Cpanel/iContact/Provider/Discord.pm /var/cpanel/perl/Cpanel/iContact/Provider/Discord.pm

install-telegram: depend-telegram install-dir
	cp -f lib/Cpanel/iContact/Provider/Schema/Telegram.pm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/Telegram.pm
	cp -f lib/Cpanel/iContact/Provider/Telegram.pm /var/cpanel/perl/Cpanel/iContact/Provider/Telegram.pm

uninstall:
	rm /var/cpanel/perl/Cpanel/iContact/Provider/Slack.pm
	rm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/Slack.pm
	rm /var/cpanel/perl/Cpanel/iContact/Provider/IRC.pm
	rm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/IRC.pm
	rm /var/cpanel/perl/Cpanel/iContact/Provider/XMPP.pm
	rm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/XMPP.pm
	rm /var/cpanel/perl/Cpanel/iContact/Provider/Discord.pm
	rm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/Discord.pm
	rm /var/cpanel/perl/Cpanel/iContact/Provider/Telegram.pm
	rm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/Telegram.pm

test: depend-all depend-test
	[ ! -x /usr/local/cpanel/3rdparty/bin/prove ] || /usr/local/cpanel/3rdparty/bin/prove t/*.t
	[ -x /usr/local/cpanel/3rdparty/bin/prove ] || prove t/*.t

depend-irc:
	perl -MIO::Socket::INET -MIO::Socket::SSL -e 'exit 0;' || sudo cpan -i IO::Socket::INET IO::Socket::SSL

depend-xmpp:
	perl -MNet::XMPP -MMozilla::CA -e 'exit 0;' || sudo cpan -i Net::XMPP Mozilla::CA

depend-telegram:
	perl -MWWW::Telegram::BotAPI -e 'exit 0;' || sudo cpan -i WWW::Telegram::BotAPI

depend-all: depend-xmpp depend-irc depend-telegram

depend-test:
	perl -MTest::More -MTest::Fatal -MTest::MockModule -MTest::Deep -MConfig::Simple -MHTTP::Tiny::UA -MHTTP::Tiny::UA::Response -e 'exit 0;' || sudo cpan -i Test::More Test::Fatal Test::MockModule Test::Deep Config::Simple HTTP::Tiny::UA HTTP::Tiny::UA::Response
