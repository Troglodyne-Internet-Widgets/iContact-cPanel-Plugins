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
	my $html    = ${ $args_hr->{'html_body'} };

    # Send it
    my $time = time;
    $time =~ tr/ /-/;
    my $user = getpwuid($<);
    my $file = "$DIR/$user/$time.json";
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
	    require Cpanel::AdminBin::Serializer;
        open( my $fh, ">", $file ) || die "Couldn't open '$file': $!";
        print $fh Cpanel::AdminBin::Serializer::Dump( { 'subject' => $subject, 'text' => $text, 'html' => $html } );
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

sub reap_older_than {
    my ($timestamp) = @_;

    return () unless -d $DIR;

    opendir(my $dh, $DIR) || die "Can't opendir $DIR: $!";
    my @actual_files = grep { !/^\./ && -f "$DIR/$_" } readdir($dh);
    closedir $dh;

    my %files_by_age = ();
    @files_by_age{@actual_files} = map { (stat "$DIR/$_")[9] } @actual_files;

    my @files_to_kill = grep { $files_by_age{$_} < $timestamp } @actual_files;

    foreach my $goner (@files_to_kill) { unlink "$DIR/$goner" or warn "Could not delete $DIR/$goner!"; }

    return @files_to_kill;
}

1;
