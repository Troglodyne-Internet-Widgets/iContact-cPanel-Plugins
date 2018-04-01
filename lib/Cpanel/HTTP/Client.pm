package Cpanel::HTTP::Client 0.0;
use parent qw{HTTP::Tiny::UA};

sub die_on_http_error { return $_[0]; }

1;
