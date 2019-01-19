package Cpanel::AdminBin::Serializer;

use Cpanel::JSON::XS ();

sub Dump {
    return Cpanel::JSON::XS->new()->allow_blessed()->encode(@_);
}

sub Load {
    return Cpanel::JSON::XS->new()->allow_blessed()->decode(@_);
}

1;
