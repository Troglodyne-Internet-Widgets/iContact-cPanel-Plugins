package Cpanel::iContact::Provider::Schema::Telegram;

use strict;
use warnings;

# Name is always uc(MODULE)

=encoding utf-8

=head1 NAME

Cpanel::iContact::Provider::Schema::Telegram - Schema for the Telegram iContact module

=head1 SYNOPSIS

    use Cpanel::iContact::Provider::Schema::Telegram;

    my $settings = Cpanel::iContact::Provider::Schema::Telegram::get_settings();

    my $config = Cpanel::iContact::Provider::Schema::Telegram::get_config();


=head1 DESCRIPTION

Provide settings and configuration for the HipChat iContact module.

=cut

=head2 get_settings

Provide config data for TweakSettings that will be saved in
/etc/wwwacct.conf.shadow

=over 2

=item Input

=over 3

None

=back

=item Output

=over 3

A hashref that can be injected into Whostmgr::TweakSettings::Basic's %Conf
with the additional help and label keys that are used in the display of the
tweak settings.

=back

=back

=cut

sub get_settings {
    my $help = <<HALP;
Telegram Bot Token: Token created for sending notifications to the bot you configured for sending cPanel & WHM Notifications to users in Telegram, separated by commas.
<br>In order to create a token for your bot, please message the BotFather in Telegram and it will make one for you.
HALP
    return {
        'CONTACTTELEGRAM' => {
            'name'     => 'Telegram Destinations',
            'shadow'   => 0,
            'type'     => 'text',
            'checkval' => sub {
                my $value = shift();
                $value =~ s/^\s+|\s+$//g; # Trim

                return $value if $value eq q{};

                return $value;
            },
            'label' => 'Telegram Destinations',
            'help'  => "The group(s)/user(s) you wish your Telegram bot to notify, separated by comma. Example: \@bogusbogus",
        },
        'TELEGRAMBOTTOKEN' => {
            'name'     => 'Telegram Bot Token',
            'label'    => 'Telegram Bot Token',
            'help'     => $help,
            'shadow'   => 1,
            'checkval' => sub {
                my $value = shift();
                $value =~ s/^\s+|\s+$//g; # Trim

                return $value if $value eq q{};

                if($value !~ m/^[0-9]+:[A-Z]{3}-[A-Z]{3}[A-Za-z0-9]+-[A-Za-z0-9]+$/ ) {
                    die "Bogus value, neener neener";
                }
                return $value;
            },
        },
    };
}

=head2 get_config

Provide configuration for the module.

=over 2

=item Input

=over 3

None

=back

=item Output

=over 3

A hash ref containing the following key values:

  default_level:    The iContact default contact level (All)
  display_name:     The name displayed on the Contact Manager page in WHM.

=back

=back

=cut

sub get_config {
    return {
        'default_level' => 'All',
        'display_name'  => 'Telegram',
        'icon' =>
          'data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%22620%22%20height%3D%22620%22%20viewBox%3D%220%200%20620%20620%22%3E%3ClinearGradient%20id%3D%22a%22%20gradientUnits%3D%22userSpaceOnUse%22%20x1%3D%22311.167%22%20y1%3D%22603.333%22%20x2%3D%22311.167%22%20y2%3D%2219%22%3E%3Cstop%20offset%3D%220%22%20stop-color%3D%22%231D93D2%22%2F%3E%3Cstop%20offset%3D%221%22%20stop-color%3D%22%2338B0E3%22%2F%3E%3C%2FlinearGradient%3E%3Ccircle%20fill%3D%22url%28%23a%29%22%20stroke%3D%22%23FFF%22%20stroke-width%3D%2228%22%20stroke-miterlimit%3D%2210%22%20cx%3D%22311.167%22%20cy%3D%22311.167%22%20r%3D%22292.167%22%2F%3E%3Cpath%20fill%3D%22%23C8DAEA%22%20d%3D%22M220.76%20338.848l35.362%2097.88s4.42%209.157%209.157%209.157%2075.146-73.252%2075.146-73.252l78.304-151.24-196.707%2092.197-1.264%2025.258z%22%2F%3E%3Cpath%20fill%3D%22%23A9C6D8%22%20d%3D%22M267.646%20363.95l-6.788%2072.146s-2.842%2022.102%2019.26%200%2043.257-39.152%2043.257-39.152%22%2F%3E%3Cpath%20fill%3D%22%23FFF%22%20d%3D%22M221.398%20342.34l-72.734-23.7s-8.683-3.526-5.894-11.525c.575-1.65%201.736-3.052%205.21-5.473%2016.12-11.234%20298.324-112.667%20298.324-112.667s7.97-2.683%2012.677-.898c2.153.816%203.527%201.737%204.685%205.104.42%201.226.663%203.83.63%206.42-.022%201.87-.252%203.6-.42%206.316-1.72%2027.732-53.145%20234.705-53.145%20234.705s-3.076%2012.113-14.103%2012.525c-4.02.15-8.9-.664-14.734-5.683-21.635-18.612-96.42-68.87-112.944-79.924-.93-.622-1.198-1.433-1.355-2.222-.233-1.165%201.034-2.61%201.034-2.61s130.217-115.75%20133.68-127.895c.268-.94-.74-1.405-2.105-1-8.65%203.183-158.58%2097.858-175.126%20108.313-.968.61-3.682.217-3.682.217z%22%2F%3E%3C%2Fsvg%3E',
    };
}

1;
