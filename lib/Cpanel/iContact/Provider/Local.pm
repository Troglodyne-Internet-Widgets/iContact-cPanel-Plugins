package Cpanel::iContact::Provider::Local;

use strict;
use warnings;

use parent 'Cpanel::iContact::Provider';

use Try::Tiny;

=encoding utf-8

=head1 NAME

Cpanel::iContact::Provider::Local - Backend for the Local iContact module

=head1 SYNOPSIS

    use Cpanel::iContact::Provider::Local;

    my $notifier = Cpanel::iContact::Provider::Local->new();
    $notifier->send();


=head1 DESCRIPTION

Provide backend accessor for the Local iContact module.

=cut

=head2 send

Sends off the notification over to /var/cpanel/iContact

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

our $DIR = '/var/cpanel/iContact_notices';

sub send {
    my ($self) = @_;

    my $args_hr    = $self->{'args'};
    my $contact_hr = $self->{'contact'};

    my @errs;

    my $subject = $args_hr->{'subject'};
    my $text    = ${ $args_hr->{'text_body'} };
    # my $html    = ${ $args_hr->{'html_body'} };

    # Send it
    my $time = localtime;
    $time =~ tr/ /-/;
    my $user = getpwuid($<);
    my $file = "$DIR/$user/$time.txt";
    try {
        # Make the dir if it doesn't exist
        if( !-d "$DIR/$user" ) {
            my $path = '/';
            foreach my $component ( split( /\//, "$DIR/$user" ) ) {
                local $!;
                $path .= "$component/";
                mkdir( $path ) || do {
                    die "Couldn't create $path: $!" if int $! != 17; # EEXISTS
                };
            }
        }
        open( my $fh, ">", $file ) || die "Couldn't open '$file': $!";
        print $fh "$subject\n\n$text\n";
        close $fh;
    }
    catch {
        require Cpanel::Exception;
        die Cpanel::Exception::create(
            'ConnectionFailed',
            'The system failed to save the message to “[_1]” due to an error: [_2]',
            [ $file, $_ ]
        );
    };

    return 1;
}

1;
