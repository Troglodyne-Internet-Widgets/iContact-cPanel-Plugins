package Cpanel::iContact::Provider::Schema::Local;

use strict;
use warnings;

# Name is always uc(MODULE)

=encoding utf-8

=head1 NAME

Cpanel::iContact::Provider::Schema::Local - Schema for the "Store Locally" iContact module

=head1 SYNOPSIS

    use Cpanel::iContact::Provider::Schema::Local;

    my $settings = Cpanel::iContact::Provider::Schema::Local::get_settings();

    my $config = Cpanel::iContact::Provider::Schema::Local::get_config();


=head1 DESCRIPTION

Provide settings and configuration for the Local iContact module.

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
Locally storing iContact notices to /var/cpanel/iContact powers the 'Notification Center' plugin in WHM.
If you don't know what that is, then you should probably turn this off.
HALP
    return {
        'CONTACTLOCAL' => {
            'name'     => 'Local',
            'type'     => 'binary',
            'label' => 'Save iContact notices locally?',
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
        'display_name'  => 'Local',
        'icon' =>
          'data:image/svg+xml,%3Csvg%20id%3D%22Layer_1%22%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20viewBox%3D%220%200%20245%20240%22%3E%3Cstyle%3E.st0%7Bfill%3A%237289DA%3B%7D%3C%2Fstyle%3E%3Cpath%20class%3D%22st0%22%20d%3D%22M104.4%20103.9c-5.7%200-10.2%205-10.2%2011.1s4.6%2011.1%2010.2%2011.1c5.7%200%2010.2-5%2010.2-11.1.1-6.1-4.5-11.1-10.2-11.1zM140.9%20103.9c-5.7%200-10.2%205-10.2%2011.1s4.6%2011.1%2010.2%2011.1c5.7%200%2010.2-5%2010.2-11.1s-4.5-11.1-10.2-11.1z%22%2F%3E%3Cpath%20class%3D%22st0%22%20d%3D%22M189.5%2020h-134C44.2%2020%2035%2029.2%2035%2040.6v135.2c0%2011.4%209.2%2020.6%2020.5%2020.6h113.4l-5.3-18.5%2012.8%2011.9%2012.1%2011.2%2021.5%2019V40.6c0-11.4-9.2-20.6-20.5-20.6zm-38.6%20130.6s-3.6-4.3-6.6-8.1c13.1-3.7%2018.1-11.9%2018.1-11.9-4.1%202.7-8%204.6-11.5%205.9-5%202.1-9.8%203.5-14.5%204.3-9.6%201.8-18.4%201.3-25.9-.1-5.7-1.1-10.6-2.7-14.7-4.3-2.3-.9-4.8-2-7.3-3.4-.3-.2-.6-.3-.9-.5-.2-.1-.3-.2-.4-.3-1.8-1-2.8-1.7-2.8-1.7s4.8%208%2017.5%2011.8c-3%203.8-6.7%208.3-6.7%208.3-22.1-.7-30.5-15.2-30.5-15.2%200-32.2%2014.4-58.3%2014.4-58.3%2014.4-10.8%2028.1-10.5%2028.1-10.5l1%201.2c-18%205.2-26.3%2013.1-26.3%2013.1s2.2-1.2%205.9-2.9c10.7-4.7%2019.2-6%2022.7-6.3.6-.1%201.1-.2%201.7-.2%206.1-.8%2013-1%2020.2-.2%209.5%201.1%2019.7%203.9%2030.1%209.6%200%200-7.9-7.5-24.9-12.7l1.4-1.6s13.7-.3%2028.1%2010.5c0%200%2014.4%2026.1%2014.4%2058.3%200%200-8.5%2014.5-30.6%2015.2z%22%2F%3E%3C%2Fsvg%3E'
    };
}

1;
