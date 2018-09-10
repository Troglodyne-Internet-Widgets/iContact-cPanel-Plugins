#!/usr/bin/perl
use strict;
use warnings;

use File::Basename qw{dirname};
use Cwd qw{abs_path};

my $gitdir = abs_path( dirname( __FILE__ ) . "/.." );
unshift @INC, "$gitdir/lib";

print "Please input the provider name you are attempting to test: ";
chomp( my $input = <STDIN> );
$input = uc($input);

my $module_name = $input;
if( $input eq 'SLACK' ) {
    $module_name = 'Slack';
}
my $package = "Cpanel::iContact::Provider::Schema::$module_name";
my $ret = eval "require $package";
die "Couldn't load $package! Check input or file permissions" if !$ret;
my $settings_hr = $package->get_settings();

my $file_name_prefix = lc( $input );
open( my $fh, ">", "$gitdir/.${file_name_prefix}testrc" );
foreach my $key ( keys( %$settings_hr ) ) {
    print "Please input the '", $settings_hr->{$key}{'label'}, "' ($key): ";
    print $fh "$key: " . <STDIN>;
}
close( $fh );

my $provepath = 'prove';
# Figure out if cPanel perl & prove exist. If so, use it, as it'll have a better chance of working.
if( -f '/usr/local/cpanel/3rdparty/bin/perl' ) {
    print "Checking cPanel Perl version...\n";
    my $cpperl_ver = `perl -e 'print substr( $], 0, 1 ) . substr( $], 3, 2 );'`;
    print "Looks like perl $cpperl_ver.\n";
    $provepath = "/usr/local/cpanel/3rdparty/perl/$cpperl_ver/bin/prove";
}

print STDOUT (
    "Done writing to $gitdir/.${file_name_prefix}testrc.\n",
    "The functional test in t/ should now work when ran like so:\n",
    "AUTHOR_TESTS=1 prove $gitdir/t/Cpanel-iContact-Provider-$module_name.t\n"
);

0;
