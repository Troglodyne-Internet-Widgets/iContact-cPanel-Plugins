package Cpanel::iContact::Provider::Schema::Slack;

use strict;
use warnings;

# Name is always uc(MODULE)

=encoding utf-8

=head1 NAME

Cpanel::iContact::Provider::Schema::Slack - Schema for the HipChat iContact module

=head1 SYNOPSIS

    use Cpanel::iContact::Provider::Schema::Slack;

    my $settings = Cpanel::iContact::Provider::Schema::Slack::get_settings();

    my $config = Cpanel::iContact::Provider::Schema::Slack::get_config();


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
Slack Incoming Webhook URL(s): URL created for sending notifications to the destination(s) you configured for the cPanel & WHM Notifications app in Slack, separated by commas.
<br />In order to create an incoming webhook for the channel(s)/user(s) you wish to notify, please go to 'Browse apps > Custom Integrations > Incoming WebHooks > New configuration'
in Slack's 'App Directory' for your team.
HALP
    return {
        'CONTACTSLACK' => {
            'name'     => 'Slack',
            'shadow'   => 1,
            'type'     => 'text',
            'checkval' => sub {
                my $value = shift();
                $value =~ s/^\s+|\s+$//g; # Trim

                return $value if $value eq q{};

                my @urls = split m{\s*,\s*}, $value;

                return join( ',', grep ( m{^https?://}, @urls ) );
            },
            'label' => 'Slack Incoming Webhook URL(s)',
            'help'  => $help,
        }
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
        'display_name'  => 'Slack',
        'icon' =>
          'data:image/svg+xml,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20id%3D%22Layer_1%22%20viewBox%3D%220%200%20121.94154%20121.84154%22%20width%3D%22121.942%22%20height%3D%22121.842%22%3E%3Cstyle%20id%3D%22style3%22%3E.st0%7Bfill%3A%23ECB32D%3B%7D%20.st1%7Bfill%3A%2363C1A0%3B%7D%20.st2%7Bfill%3A%23E01A59%3B%7D%20.st3%7Bfill%3A%23331433%3B%7D%20.st4%7Bfill%3A%23D62027%3B%7D%20.st5%7Bfill%3A%2389D3DF%3B%7D%20.st6%7Bfill%3A%23258B74%3B%7D%20.st7%7Bfill%3A%23819C3C%3B%7D%3C%2Fstyle%3E%3Cg%20id%3D%22g5%22%3E%3Cg%20id%3D%22g7%22%3E%3Cpath%20class%3D%22st0%22%20d%3D%22M79.03%207.51c-1.9-5.7-8-8.8-13.7-7-5.7%201.9-8.8%208-7%2013.7l28.1%2086.4c1.9%205.3%207.7%208.3%2013.2%206.7%205.8-1.7%209.3-7.8%207.4-13.4%200-.2-28-86.4-28-86.4z%22%20id%3D%22path9%22%20fill%3D%22%23ecb32d%22%2F%3E%3Cpath%20class%3D%22st1%22%20d%3D%22M35.53%2021.61c-1.9-5.7-8-8.8-13.7-7-5.7%201.9-8.8%208-7%2013.7l28.1%2086.4c1.9%205.3%207.7%208.3%2013.2%206.7%205.8-1.7%209.3-7.8%207.4-13.4%200-.2-28-86.4-28-86.4z%22%20id%3D%22path11%22%20fill%3D%22%2363c1a0%22%2F%3E%3Cpath%20class%3D%22st2%22%20d%3D%22M114.43%2079.01c5.7-1.9%208.8-8%207-13.7-1.9-5.7-8-8.8-13.7-7l-86.5%2028.2c-5.3%201.9-8.3%207.7-6.7%2013.2%201.7%205.8%207.8%209.3%2013.4%207.4.2%200%2086.5-28.1%2086.5-28.1z%22%20id%3D%22path13%22%20fill%3D%22%23e01a59%22%2F%3E%3Cpath%20class%3D%22st3%22%20d%3D%22M39.23%20103.51c5.6-1.8%2012.9-4.2%2020.7-6.7-1.8-5.6-4.2-12.9-6.7-20.7l-20.7%206.7%206.7%2020.7z%22%20id%3D%22path15%22%20fill%3D%22%23331433%22%2F%3E%3Cpath%20class%3D%22st4%22%20d%3D%22M82.83%2089.31c7.8-2.5%2015.1-4.9%2020.7-6.7-1.8-5.6-4.2-12.9-6.7-20.7l-20.7%206.7%206.7%2020.7z%22%20id%3D%22path17%22%20fill%3D%22%23d62027%22%2F%3E%3Cpath%20class%3D%22st5%22%20d%3D%22M100.23%2035.51c5.7-1.9%208.8-8%207-13.7-1.9-5.7-8-8.8-13.7-7l-86.4%2028.1c-5.3%201.9-8.3%207.7-6.7%2013.2%201.7%205.8%207.8%209.3%2013.4%207.4.2%200%2086.4-28%2086.4-28z%22%20id%3D%22path19%22%20fill%3D%22%2389d3df%22%2F%3E%3Cpath%20class%3D%22st6%22%20d%3D%22M25.13%2059.91c5.6-1.8%2012.9-4.2%2020.7-6.7-2.5-7.8-4.9-15.1-6.7-20.7l-20.7%206.7%206.7%2020.7z%22%20id%3D%22path21%22%20fill%3D%22%23258b74%22%2F%3E%3Cpath%20class%3D%22st7%22%20d%3D%22M68.63%2045.81c7.8-2.5%2015.1-4.9%2020.7-6.7-2.5-7.8-4.9-15.1-6.7-20.7l-20.7%206.7%206.7%2020.7z%22%20id%3D%22path23%22%20fill%3D%22%23819c3c%22%2F%3E%3C%2Fg%3E%3C%2Fg%3E%3C%2Fsvg%3E'
    };
}

1;
