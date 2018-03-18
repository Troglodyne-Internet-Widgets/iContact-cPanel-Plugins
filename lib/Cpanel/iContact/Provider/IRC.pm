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

    my $subject = $args_hr->{'subject'};
    my $body    = ${ $args_hr->{'text_body'} };

	local $@;
	eval {
		my $response;
		$self->_send(
			'destination' => $args_hr->{'to'}[0],
			'subject'     => $subject,
			'content'     => $body
		);
	};
	push( @errs, $@ ) if $@;

    if (@errs) {
        die "One or more notification attempts failed. Details below:\n"
          . join( "\n", @errs );
    }

    return 1;
}

my $conn;
sub _send {
    my ( $self, %args ) = @_;

    if( $ENV{'AUTHOR_TESTS'} ) {
        my $debugmsg = "# Attempting connection to $self->{'contact'}{'IRCSERVER'}:$self->{'contact'}{'IRCPORT'} as $self->{'contact'}{'IRCNICK'} in channel $args{'destination'}";
        $debugmsg   .= " using SSL" if $self->{'contact'}{'IRCUSESSL'};
        print $debugmsg, "\n";
    }
    my @message_lines = _format_message_for_irc( $args{'subject'}, $args{'content'}, $args{'destination'} );

    require IO::Socket::INET;
    require IO::Socket::SSL;
    require Time::HiRes;

    # Don't laugh, some of these notices are so long (and the server so laggy at printing) that this actually is reasonable.
    # Usually messages are delayed as a flood limiting action.
    local $SIG{'ALRM'} = sub { die "Timed out waiting for notification to post to IRC channel!" };
    alarm(10);

    $conn = IO::Socket::INET->new("$self->{'contact'}{'IRCSERVER'}:$self->{'contact'}{'IRCPORT'}", ) or die $!;
    binmode( $conn, ":utf8" );
    if( $self->{'contact'}{'IRCUSESSL'} ) {
        print "# Upgrading connection to use SSL...\n" if $ENV{'AUTHOR_TESTS'};
        IO::Socket::SSL->start_SSL( $conn, 'SSL_HOSTNAME' => $self->{'contact'}{'IRCSERVER'}, 'SSL_verify_mode' => 0 ) or die $IO::Socket::SSL::ERROR;
    }
    print "# [SENT] NICK $self->{'contact'}{'IRCNICK'}\r\n" if $ENV{'AUTHOR_TESTS'};
    print $conn "NICK $self->{'contact'}{'IRCNICK'}\r\n";
    print "# [SENT] USER cpsaurus * 8 :cPanel & WHM Notification Bot v0.1 (github.com/troglodyne/iContact-cPanel-Plugins)\r\n" if $ENV{'AUTHOR_TESTS'};
    print $conn "USER cpsaurus * 8 :cPanel & WHM Notification Bot v0.1 (github.com/troglodyne/iContact-cPanel-Plugins)\r\n";
  
    my %got;
    while( $conn ) {

        last if !scalar(@message_lines);
        
        # Print it all then leave like a bad smell
        if( $got{'366'} && $got{'332'} ) {
            foreach my $shake_line ( @message_lines ) {
                print "# [SENT] $shake_line" if $ENV{'AUTHOR_TESTS'};
                print $conn $shake_line;
            }
            last;
        }

        my $line= readline( $conn ) || "";
        #$line =~ s/^[^[:print:]]+$//; # Collapse blank lines
        next if !$line;
        print "# [GOT][" . length($line) . "] $line" if $ENV{'AUTHOR_TESTS'};
        my @msgparts = split( ' ', $line );
        $msgparts[1] ||= '';
        # PING handler
        if( $msgparts[0] eq 'PING' ) {
            print "# [SENT] PONG $msgparts[1]\r\n" if $ENV{'AUTHOR_TESTS'};
            print $conn "PONG $msgparts[1]\r\n";
            next;
        }
        # MOTD/JOIN handler
        if( grep { $_ eq $msgparts[1] } qw{376 422} ) {
            print "# [SENT] JOIN $args{'destination'}\r\n" if $ENV{'AUTHOR_TESTS'};
            print $conn "JOIN $args{'destination'}\r\n";
            next;
        }
        # Channel join handler, gotta wait for NAMES and TOPIC
        if( grep { $_ eq $msgparts[1] } qw{366 332} ) {
            print "# [INFO] Noticed we got $msgparts[1] above. Noting that so we can know when to start spamming messages.\n" if $ENV{'AUTHOR_TESTS'};

            $got{"$msgparts[1]"} = 1 ;
            next;
        }
    }
    print "# [SENT] QUIT :Done sending notification\r\n" if $ENV{'AUTHOR_TESTS'};
    print $conn "QUIT :Done sending notification\r\n";
    # The connection won't properly un-block until you read the response from QUIT.
    # Unfortunately, just setting it to non-block leads to your messages not being processed.
    # As such, just read here and let it do it's thing even though you don't actually need the data.
    readline( $conn );
    $conn->shutdown(2);

    return;
}

# https://tools.ietf.org/html/rfc2812#section-2.3
sub _format_message_for_irc {
    my ( $subj, $body, $chan ) = @_;
    my @msg_lines;

    my $prefix = "NOTICE $chan :";
    my $suffix = "\r\n"; # 2 chars
    my $msglen = 510 - length $prefix; # 512 chars total

    # Subject is one line
    while( $subj ) {
        if( length $subj <= 510 ) {
            push( @msg_lines, $prefix . $subj . $suffix );
            undef $subj;
        } else {
            push( @msg_lines, $prefix . substr( $subj, 0, 510, "" ) . $suffix );
        }
    }

    # Body is multiline
    my @body_lines = split( "\n", $body );
    foreach my $line (@body_lines) {
        while( $line ) {
            if( length $line <= 510 ) {
                push( @msg_lines, $prefix . $line . $suffix );
                undef $line;
            } else {
                push( @msg_lines, $prefix . substr( $line, 0, 510, "" ) . $suffix );
            }
        }
    }

    return @msg_lines;
}

sub DESTROY {
    $conn->shutdown(2) if $conn;
}

1;
