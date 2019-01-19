#!/usr/local/cpanel/3rdparty/bin/perl

package LocaliContactReaper;

use strict;
use warnings;

use Getopt::Long ();

use lib '/var/cpanel/perl';

use Cpanel::iContact::Provider::Local;

exit main(@ARGV) unless caller();

sub main {
    my @args = @_;
    my $days;

    Getopt::Long::GetOptionsFromArray(\@args,
        'days=i' => \$days,
    );
    $days ||= 30;

    my $timestamp = time() - (int($days) * 86400 );

    my @reaped = Cpanel::iContact::Provider::Local::reap_older_than($timestamp);
    foreach my $goner (@reaped) {
        print "Reaped $goner for being older than $timestamp...\n";
    }
    print "Done!\n";
    return 0;
}

1;
