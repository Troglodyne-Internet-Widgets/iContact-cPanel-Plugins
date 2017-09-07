package Cpanel::iContact::Provider::Slack;

use strict;
use warnings;

use parent 'Cpanel::iContact::Provider';

use Try::Tiny;
use Cpanel::LoadModule ();

=encoding utf-8

=head1 NAME

Cpanel::iContact::Provider::Slack - Backend for the Slack iContact module

=head1 SYNOPSIS

    use Cpanel::iContact::Provider::Slack;

    my $notifier = Cpanel::iContact::Provider::Slack->new();
    $notifier->send();


=head1 DESCRIPTION

Provide backend accessor for the Slack iContact module.

=cut

=head2 send

Sends off the notification over to your hipchat room/user

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

    Cpanel::LoadModule::load_perl_module("Cpanel::HTTP::Client");
    my $ua = Cpanel::HTTP::Client->new( 'default_headers' => { 'content-type' => 'application/json' } )->die_on_http_error();

    my $subject = $args_hr->{'subject'};
    my $message = ${ $args_hr->{'text_body'} };

    Cpanel::LoadModule::load_perl_module("Cpanel::AdminBin::Serializer");
    my $message_json = Cpanel::AdminBin::Serializer::Dump(
        {
            'text'        => $subject,
            'attachments' => [ { "text" => $message } ],
        }
    );

    # Send it
    foreach my $destination ( @{ $args_hr->{'to'} } ) {
        try {
            my $res = $ua->request( 'POST', $destination, { 'content' => $message_json } );
            die( sprintf "Error %d: %s", $res->status(), $res->reason() ) if !$res->success();
        }
        catch {
            Cpanel::LoadModule::load_perl_module("Cpanel::Exception");
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
