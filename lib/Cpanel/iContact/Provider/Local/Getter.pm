package Cpanel::iContact::Provider::Local::Getter;

use strict;
use warnings;

# Specifically for the constant that is the dir
use Cpanel::iContact::Provider::Local ();
use Cpanel::AdminBin::Serializer      ();

=encoding utf-8

=head1 NAME

Cpanel::iContact::Provider::Local::Getter - Get notifications stored by the "Store Locally" iContact module

=head1 SYNOPSIS

    use lib '/var/cpanel/perl';
    use Cpanel::iContact::Provider::Local::Getter;

    # Get the latest notification
    my @notification_times = Cpanel::iContact::Provider::Local::Getter::get_notice_times( 'user' => 'root' );
    my $notification = Cpanel::iContact::Provider::Local::Getter::get_notice( $notification_times[0], 'user' => 'root');
    ...

    # OK, let's get ALL notifications AND their text
    my %notifications = Cpanel::iContact::Provider::Local::Getter::get_all_notices( 'user' => 'root' );

=head1 DESCRIPTION

Provide a way to retrieve locally saved iContact notices.

=cut

=head2 get_notice_times

=over 2

=item Input (hash)

=over 3

user: (required) specify the user to get these things for

=back

=item Output (array)

=over 3

UNIX Epoch timestamps sorted by latest date first.

=back

=back

=cut

# Note, since there's only one hash param (for now) just ref second item in array
sub get_notice_times {
    return sort( map { substr( $_, rindex( $_, '/' ), -5 ) } grep { qr/\d+\.json/ } glob( $Cpanel::iContact::Provider::Local::DIR . "/$_[1]/*.json" ) );
}

=head2 get_notice

=over 2

=item Input (mixed)

=over 3

time: (integer/string) Time to look for, get em from get_notice_times above

user: (hash param) specify the user to get these things for

=back

=item Output (string)

=over 3

Notification contents.

=back

=back

=cut

sub get_notice {
	my ( $time, %opts ) = @_;
	local $/;
	my $file = $Cpanel::iContact::Provider::Local::DIR . "/$opts{'user'}/$time.json";
	open my $fh, '<', $file or die "can't open $file: $!";
    return Cpanel::AdminBin::Serializer::Load(<$fh>);
}

=head2 get_all_notices

=over 2

=item Input (hash)

=over 3

user: (required) specify the user to get these things for

=back

=item Output (hash)

=over 3

time => notification contents.

=back

=back

=cut

sub get_all_notices {
	my $user = $_[1];
	return map {
		my $time = substr( $_, rindex( $_, '/' ), -5 ); $time => get_notice( $time, 'user' => $user );
	} grep {
		qr/\d+\.json/
	} glob( $Cpanel::iContact::Provider::Local::DIR . "/$user/*.json" );
}

1;
