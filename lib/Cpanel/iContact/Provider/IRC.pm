package Cpanel::iContact::Provider::IRC;

use strict;
use warnings;

use parent 'Cpanel::iContact::Provider';

sub send {
    my ($self) = @_;
    my @missing = grep { !defined $self->{'contact'}{$_} } qw{IRCSERVER};
    die "Kit not complete! Missing: " . join( ", ", @missing ) if scalar( @missing );

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
    my $bot = Bot::BasicBot->new(
        'server'   => $self->{'contact'}{'IRCSERVER'},
        'port'     => $self->{'contact'}{'IRCPORT'} || 6667,
        'channels' => $args{'destination'},
        'nick'     => $self->{'contact'}{'IRCNICK'} || 'cPanel_&_WHM',
        'ssl'      => $self->{'contact'}{'IRCUSESSL'},
    );
    $bot->say( { 'body' => $args{'subject'} } );
    $bot->say( { 'body' => $args{'content'} } );
    $bot->shutdown();

    return;
}

1;
