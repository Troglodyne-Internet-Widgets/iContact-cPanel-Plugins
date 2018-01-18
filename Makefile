install:
	make depend
	[ -d /var/cpanel/perl/Cpanel/iContact/Provider/Schema ] || mkdir -p /var/cpanel/perl/Cpanel/iContact/Provider/Schema/
	cp -f lib/Cpanel/iContact/Provider/Schema/*.pm /var/cpanel/perl/Cpanel/iContact/Provider/Schema/
	cp -f lib/Cpanel/iContact/Provider/*.pm /var/cpanel/perl/Cpanel/iContact/Provider/

test:
	make depend
	[ ! -x /usr/local/cpanel/3rdparty/bin/prove ] || /usr/local/cpanel/3rdparty/bin/prove t/*.t
	[ -x /usr/local/cpanel/3rdparty/bin/prove ] || prove t/*.t

depend:
	perl -MNet::XMPP -MMozilla::CA -MTest::More -MTest::Fatal -MTest::MockModule -MConfig::Simple -MBot::BasicBot -MPOE::Component::SSLify -e 'exit 0;' || sudo cpan -i Net::XMPP Mozilla::CA Test::More Test::Fatal Test::MockModule Config::Simple Bot::BasicBot POE::Component::SSLify
