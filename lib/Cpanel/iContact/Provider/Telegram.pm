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
    $api->getMe(); # Should explode if bogus?

    my $subject = $args_hr->{'subject'};
    my $message = $args_hr->{'text_body'};

    # Send it
    foreach my $destination ( @{ $args_hr->{'to'} } ) {
        try {
            $api->sendMessage(
                'chat_id' => $destination,
                'text'    => $message,
            );
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
