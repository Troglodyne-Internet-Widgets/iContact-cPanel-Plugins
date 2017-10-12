package Cpanel::iContact::Provider::IRC;

use strict;
use warnings;

use parent 'Cpanel::iContact::Provider';

sub send {
    my ($self) = @_;

    my $args_hr = $self->{'args'};
    my @errs;

    my $subject_copy = $args_hr->{'subject'};
    my $body_copy    = ${ $args_hr->{'text_body'} };

    require Encode;
    my $subject      = Encode::decode_utf8( $subject_copy, $Encode::FB_QUIET );
    my $body         = Encode::decode_utf8( $body_copy, $Encode::FB_QUIET );

    foreach my $destination ( @{ $args_hr->{'to'} } ) {
        local $@;
        eval {
            my $response;
            $self->_send(
                'destination' => $destination,
                'subject' => $subject,
                'content' => $body
            );
        };
        push( @errs, $@ ) if $@;
    }

    if (@errs) {
        die "One or more notification attempts failed. Details below:\n"
          . join( "\n", @errs );
    }

    return 1;
}

sub _send {
    my ( $self, %args ) = @_;
    require Bot::BasicBot;

    return;
}

1;
