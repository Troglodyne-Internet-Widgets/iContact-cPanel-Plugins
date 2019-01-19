use strict;
use warnings;

use Cwd qw{abs_path};
use File::Basename qw{dirname};
use lib abs_path( dirname(__FILE__) . "/../lib" );

use Test::More;
use Test::Fatal;
use File::Temp ();

use Cpanel::iContact::Provider::Local         ();
use Cpanel::iContact::Provider::Local::Getter ();

plan tests => 1;

# First, let's mock out the parent, and other stuff we wouldn't wanna do in a unit test
subtest "Provider bits work as expected ('unit' test)" => sub {
    plan tests => 7;
    # Create tempdir for jamming stuff into
    my $tmp_obj = File::Temp->newdir();
    my $tmp_dir = $tmp_obj->dirname;
    $Cpanel::iContact::Provider::Local::DIR = "$tmp_dir/iContact_notices";

    #  Make the notice send
    isa_ok( my $spammer = Cpanel::iContact::Provider::Local->new(), "Cpanel::iContact::Provider::Local" );
    my $ex = exception { $spammer->send() };
    is( $ex, undef, "send doesn't throw on GreatSuccess" ) || diag explain $ex;
    my $user = getpwuid($<);
    my @files = glob( "$tmp_dir/iContact_notices/$user/*.json" );
    ok( scalar(@files), "Looks like a file was written..." ) || diag explain \@files;
    like( $files[0], qr/\d\.json/, "..and it looks like we'd expect it to" ) || diag explain \@files;

    # Now let's check on them another way
    my %notifications = Cpanel::iContact::Provider::Local::Getter::get_all_notices( 'user' => $user );
    ok( scalar(keys(%notifications)), "Got the expected notifications from hash..." ) || diag explain \%notifications;
    like( (keys(%notifications))[0], qr/\d+/, "..and the hash key looks like we'd expect it to" ) || diag explain \%notifications;
    is_deeply( [ sort keys(%{ $notifications{(keys(%notifications))[0]} }) ], [ 'html', 'subject', 'text' ], "%notifications{time} hashref has has the right keys" );
};
