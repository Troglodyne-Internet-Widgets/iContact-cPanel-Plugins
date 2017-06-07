package Cpanel::iContact::Provider::XMPP;

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
    # Unfortunately you need this for Net::XMPP::Client to work.
    # Just requiring Net::XMPP::Client won't work.
    require Net::XMPP;

    my $user_name = substr( $self->{'contact'}{'XMPPUSERNAME'}, 0, index( $self->{'contact'}{'XMPPUSERNAME'}, '@' ));
    my $srvr_name = substr( $self->{'contact'}{'XMPPUSERNAME'}, index( $self->{'contact'}{'XMPPUSERNAME'}, '@' ) + 1 );
    # Safest assumption unless we the user gives a component name for override is to use base server name
    # Otherwise, expect a lot of "host-unknown" errors.
    my $cmpt_name = $self->{'contact'}{'XMPPCOMPONENTNAME'} || $srvr_name;
    my $xmpp_conn = Net::XMPP::Client->new(
        # Uncomment the below for debugging info
        #'debuglevel' => 2,
        #'debugfile'  => "/usr/local/cpanel/logs/error_log",
    );

    require Mozilla::CA;

    # Will splash down without this
    my $cab_loc = Mozilla::CA::SSL_ca_file();

    # SIGALRM this to put a stop to folks who don't set SSL/TLS settings right (as Connect then foreverloops)
    my $status;
    {
        local $SIG{'ALRM'} = sub { die "Error: XMPP Connection failed: Timeout while attempting connection\n" };
        $self->{'_xmpp_alarm'} ||= 5; # For tests
        alarm $self->{'_xmpp_alarm'};
        $status = $xmpp_conn->Connect(
            'hostname'      => $srvr_name,
            'componentname' => $cmpt_name,
            'tls'           => $self->{'contact'}{'XMPPUSETLS'},
            'srv'           => 1,
            'ssl_ca_path'   => $cab_loc,
            'ssl_verify'    => $self->{'contact'}{'XMPPVERIFYCERT'},
        );
        alarm 0;
    }
    if( !defined($status) ) {
        require Data::Dumper;
        die("Error: XMPP connection failed: " . Data::Dumper::Dumper($xmpp_conn->GetErrorCode()) );
    }

    my @result = $xmpp_conn->AuthSend(
        'username'    => $user_name,
        'password'    => $self->{'contact'}{'XMPPPASSWORD'},
        'resource'    => 'cPanel & WHM',
    );
    if( !@result || $result[0] ne "ok" ) {
        require Data::Dumper;
        die("Error: XMPP authentication failed: " . Data::Dumper::Dumper($xmpp_conn->GetErrorCode()) );
    }

    # TODO Error handling? There doesn't seem to be a good return from this sub.
    $xmpp_conn->MessageSend(
        'to'       => $args{'destination'},
        'subject'  => $args{'subject'},
        'body'     => $args{'content'},
        'thread'   => "cPNotifySpam",
        'priority' => 10,
    );
    $xmpp_conn->Disconnect();

    return;
}

1;
