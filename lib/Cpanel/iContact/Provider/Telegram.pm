package Cpanel::iContact::Provider::Discord;

use strict;
use warnings;

use parent 'Cpanel::iContact::Provider';

use Try::Tiny;

=encoding utf-8

=head1 NAME

Cpanel::iContact::Provider::Discord - Backend for the Discord iContact module

=head1 SYNOPSIS

    use Cpanel::iContact::Provider::Discord;

    my $notifier = Cpanel::iContact::Provider::Discord->new();
    $notifier->send();


=head1 DESCRIPTION

Provide backend accessor for the Discord iContact module.

=cut

=head2 send

Sends off the notification over to your Discord channel/user

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

    my @errs;

    require Cpanel::HTTP::Client;
    my $ua = Cpanel::HTTP::Client->new( 'default_headers' => { 'content-type' => 'application/json' } )->die_on_http_error();

    my $subject = $args_hr->{'subject'};
    my $message = ${ $args_hr->{'text_body'} };

    require Cpanel::AdminBin::Serializer;

    # GitHub issue #18 -- Discord max message length is 2000 chars.
    # As such , truncate at 1996, add ellipsis (3 chars).
    # Why not 1997? I want to avoid fencepost errors.
    my $message_json = Cpanel::AdminBin::Serializer::Dump(
        {
            'content'     => substr( "$subject\n\n$message", 0, 1996 ) . "...",
        }
    );

    # Send it
    foreach my $destination ( @{ $args_hr->{'to'} } ) {
        try {
            my $res = $ua->request( 'POST', $destination, { 'content' => $message_json } );
            die( sprintf "Error %d: %s", $res->status(), $res->reason() ) if !$res->success();
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
