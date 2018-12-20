use strict;
use warnings;

use Cwd qw{abs_path};
use File::Basename qw{dirname};
use lib abs_path( dirname(__FILE__) . "/../lib" );

use Test::More;
use Test::Fatal;
use File::Temp ();

use Cpanel::iContact::Provider::Local ();

plan tests => 1;

# First, let's mock out the parent, and other stuff we wouldn't wanna do in a unit test
subtest "Provider bits work as expected ('unit' test)" => sub {

    # Create tempdir for jamming stuff into
    my $tmp_obj = File::Temp->newdir();
    my $tmp_dir = $tmp_obj->dirname;
    $Cpanel::iContact::Provider::Local::DIR = "$tmp_dir/iContact_notices";

    #  Make the notice send
    isa_ok( my $spammer = Cpanel::iContact::Provider::Local->new(), "Cpanel::iContact::Provider::Local" );
    my $ex = exception { $spammer->send() };
    is( $ex, undef, "send doesn't throw on GreatSuccess" ) || diag explain $ex;
    my @files = glob( "$tmp_dir/iContact_notices/*.txt" );
    ok( scalar(@files), "Looks like a file was written..." );

    # Thu-Dec-20-13:46:46-2018 
    like( $files[0], qr/[A-Z][a-z]{2}-[A-Z][a-z]{2}-\d{2}-\d{2}:\d{2}:\d{2}-\d{4}\.txt/, "..and it looks like we'd expect it to" ) || diag explain \@files;
    #diag `cat $files[0]`;
};
