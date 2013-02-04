package Net::Abuse::Spamcheck;

use Moose;
use MooseX::Types::NetAddr::IP qw( NetAddrIP NetAddrIPv4 NetAddrIPv6 );
use MooseX::Types::IPv4 qw/ip2 ip3 ip4/;
our $VERSION = '0.0.1';

has 'ip' => (
    is       => 'rw',
    isa      => NetAddrIPv4,
    coerce   => 1,
);

has 'dnsbl' => (
    is         => 'rw',
    isa        => 'ArrayRef[Str]',
    lazy_build => 1,
);


__PACKAGE__->meta->make_immutable;

no Moose;

#--------------

use Net::Abuse::Utils qw( :all );

sub _build_dnsbl {
    my $self = shift;
    my @dnsbl_list = (
        # http://cpansearch.perl.org/src/MIKEGRB/Net-Abuse-Utils-0.11/examples/ip-info.pl
        'zen.spamhaus.org',
        'bl.spamcop.net',
        'cbl.abuseat.org',
    );
    return \@dnsbl_list;
}

sub check_spam {
    my ($self, @dnsbl_list) = @_;
    my %ret;

    foreach my $dnsbl ( @dnsbl_list ) {
        my $ret = get_dnsbl_listing( $self->ip->addr(), $dnsbl );

        if ( defined( $ret ) ) {
            $ret{$dnsbl} = $ret;
        }

    }

    return %ret;
}

sub run {
    my $self = shift;
    my %return;


    %{ $return{$self->ip->addr()} } = $self->check_spam( @{ $self->dnsbl } );
    return %return;
}

1;
