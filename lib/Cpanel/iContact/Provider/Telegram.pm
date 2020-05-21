package Cpanel::iContact::Provider::Telegram;

use strict;
use warnings;

use parent 'Cpanel::iContact::Provider';

use Try::Tiny;

=encoding utf-8

=head1 NAME

Cpanel::iContact::Provider::Telegram - Backend for the Telegram iContact module

=head1 SYNOPSIS

    use Cpanel::iContact::Provider::Telegram;

    my $notifier = Cpanel::iContact::Provider::Telegram->new();
    $notifier->send();


=head1 DESCRIPTION

Provide backend accessor for the Telegram iContact module.

=cut

=head2 send

Sends off the notification over to your Telegram channel/user

=over 2

=item Input

=over 3

None

=back

=item Output

=over 3

Truthy value on success, exception on failure.

=back

=back

=cut

sub send {
    my ($self) = @_;

    my $args_hr    = $self->{'args'};
    my $contact_hr = $self->{'contact'};

    my @missing = grep { !defined $self->{'contact'}{$_} } qw{TELEGRAMBOTTOKEN};
    die "Kit not complete! Missing: " . join( ", ", @missing ) if scalar( @missing );

    my @errs;

    # Telegram max message length is 4096 chars.
    # As such , truncate at 4092, add ellipsis (3 chars).
    # Why not 4093? I want to avoid fencepost errors.
    # Also, mojibake worries... oof
    require Encode;
    my $subject      = Encode::decode_utf8( $args_hr->{'subject'}, $Encode::FB_QUIET );
    my $body         = Encode::decode_utf8( ${$args_hr->{'text_body'}}, $Encode::FB_QUIET );
    my $message = substr( "$subject\n$body", 0, 4092 );
    $message .= '...' if length $message == 4092;

    # Disgusting, but whatever. We are about to have some fun here boyos
    # First, gotta load our libs
    # Second, the mojo that comes with cP is titanic.
    # Mojo you install from cpan won't work with cP binaries
    # Disaster all around.
    # Get around it by forcing the module into LWP mode, lol
    push @INC, '/usr/local/share/perl5';
    require WWW::Telegram::BotAPI;
    my $api = WWW::Telegram::BotAPI->new(
        token     => $self->{'contact'}{'TELEGRAMBOTTOKEN'},
        force_lwp => 1,
    );

    # Test the auth. Will die if it fails.
    $api->getMe();


    # Send it
    foreach my $destination ( @{ $args_hr->{'to'} } ) {
        try {
            $api->sendMessage({
                'chat_id'    => $destination,
                'text'       => $message,
            });
        }
        catch {
            require Cpanel::Exception;
            push(
                @errs,
                Cpanel::Exception::create(
                    'ConnectionFailed',
                    'The system failed to send the message to “[_1]” due to an error: [_2]',
                    [ $destination, $_ ]
                )
            );
        };
    }

    if (@errs) {

        # Module should already be loaded above
        die Cpanel::Exception::create( 'Collection', [ exceptions => \@errs ] );
    }

    return 1;
}

1;
