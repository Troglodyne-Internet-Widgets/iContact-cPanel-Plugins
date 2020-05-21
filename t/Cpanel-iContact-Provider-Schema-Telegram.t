use strict;
use warnings;

use Cwd qw{abs_path};
use File::Basename qw{dirname};
use lib abs_path( dirname(__FILE__) . "/../lib" );

use Test::More;
use Test::Deep;

use Cpanel::iContact::Provider::Schema::Telegram ();

plan tests => 2;

subtest "Settings getter method performs as expected" => sub {
    my $model = [ 'CONTACTTELEGRAM', 'TELEGRAMBOTTOKEN' ];
    my $settings = Cpanel::iContact::Provider::Schema::Telegram::get_settings();
    is_deeply( [ sort keys( %{$settings} ) ], $model, "Settings returned look OK so far" );
    foreach my $key (@$model) {
        is(
            $settings->{$key}{'checkval'}->('123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11'),
            '123456:ABC-DEF1234ghIkl-zyx57W2v1u123ew11', "Valid values passed to checkval subroutine of '$key' assumed GreatSuccess"
        ) if ref $settings->{$key}{'checkval'} eq 'CODE';
    }
    is( $settings->{'CONTACTTELEGRAM'}{'checkval'}->('    '), '', "Invalid values passed to checkval subroutine of 'CONTACTTELEGRAM' silently got smashed" );
    is( eval { $settings->{'TELEGRAMBOTTOKEN'}{'checkval'}->(' NeenerNeenerNotAToken') }, undef, "Invalid values passed to checkval subroutine of 'CONTACTTELEGRAM' engaged Maximum NO" );
};

my $config_model = { 'default_level' => 'All', 'display_name' => 'Telegram', 'icon' => ignore() };
cmp_deeply( Cpanel::iContact::Provider::Schema::Telegram::get_config(), $config_model, "Config getter method return looks OK" );
