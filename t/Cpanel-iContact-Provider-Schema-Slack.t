use strict;
use warnings;

use Cwd qw{abs_path};
use File::Basename qw{dirname};
use lib abs_path( dirname(__FILE__) . "/../lib" );

use Test::More;
use Test::Deep;

use Cpanel::iContact::Provider::Schema::Slack ();

plan tests => 2;

subtest "Settings getter method performs as expected" => sub {
    my $model = [ 'CONTACTSLACK' ];
    my $settings = Cpanel::iContact::Provider::Schema::Slack::get_settings();
    is_deeply( [ sort keys( %{$settings} ) ], $model, "Settings returned look OK so far" );
    foreach my $key (@$model) {
        is(
            $settings->{$key}{'checkval'}->('https://foo.bar.baz'),
            'https://foo.bar.baz', "Valid values passed to checkval subroutine of '$key' assumed GreatSuccess"
        ) if ref $settings->{$key}{'checkval'} eq 'CODE';
    }
    is( $settings->{'CONTACTSLACK'}{'checkval'}->('    '), '', "Invalid values passed to checkval subroutine of 'CONTACTSLACK' engaged Maximum NO" );
};

my $config_model = { 'default_level' => 'All', 'display_name' => 'Slack', 'icon' => ignore() };
cmp_deeply( Cpanel::iContact::Provider::Schema::Slack::get_config(), $config_model, "Config getter method return looks OK" );
