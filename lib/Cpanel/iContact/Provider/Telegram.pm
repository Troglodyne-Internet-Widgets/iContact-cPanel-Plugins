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

    require WWW::Telegram::BotAPI;
    my $api = WWW::Telegram::BotAPI->new(
        token => $self->{'contact'}{'TELEGRAMBOTTOKEN'},
    );

    # Test the auth. Will die if it fails.
    $api->getMe();

    # Telegram max message length is 4096 chars.
    # As such , truncate at 4092, add ellipsis (3 chars).
    # Why not 4093? I want to avoid fencepost errors.
    my $message = substr( $args_hr->{'subject'} . "\n" . ${$args_hr->{'text_body'}}, 0, 4092 );
    $message .= '...' if length $message == 4092;

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
        use Data::Dumper;
        print Dumper(\@errs);
        # Module should already be loaded above
        die Cpanel::Exception::create( 'Collection', [ exceptions => \@errs ] );
    }

    return 1;
}

1;
