#!/usr/local/cpanel/3rdparty/bin/perl

package WHM::Plugin::NotificationCenter;

use strict;
use warnings;

use CGI qw/:standard/;
print header();

use Cpanel::Template;

use lib '/var/cpanel/perl';

use Cpanel::iContact::Provider::Local::Getter;

main() unless caller;

sub main {

    my %notices = Cpanel::iContact::Provider::Local::Getter::get_all_notices( user => $ENV{REMOTE_USER} || 'root' );
    my $vars = {
        notifications => \%notices,
    };

    Cpanel::Template::process_template( 'whostmgr', { template_file => 'addon_notification-center.tmpl', data => $vars } );

    return 0;
}

1;
