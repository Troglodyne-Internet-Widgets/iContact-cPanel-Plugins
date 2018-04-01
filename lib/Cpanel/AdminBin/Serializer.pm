package Cpanel::AdminBin::Serializer;

use Cpanel::JSON::XS ();

sub Dump {
    return Cpanel::JSON::XS->new()->allow_blessed()->encode(@_);
}

1;
