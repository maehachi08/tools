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
use Data::Printer;

sub _build_dnsbl {
    my $self = shift;
    my @dnsbl_list = (
        # http://cpansearch.perl.org/src/MIKEGRB/Net-Abuse-Utils-0.11/examples/ip-info.pl
        'zen.spamhaus.org',
        'bl.spamcop.net',
        'cbl.abuseat.org',
        'cdl.anti-spam.org.cn',
        'dul.dnsbl.sorbs.net',
        'dnsbl.ahbl.org',
        'aspews.dnsbl.sorbs.net',
        'ips.backscatterer.org',
        'barracudacentral.org',
        'bl.blocklist.de',
        'bsb.spamlookup.net',
        'dnsbl.burnt-tech.com',
        'rbl.choon.net',
        'dnsbl.sorbs.net',
        'cbl.abuseat.org',
        'rbl.dns-servicios.com',
        'rbl.efnet.org',
        'spamrbl.imp.ch',
        'dnsbl.inps.de',
        'rbl.interserver.net',
        'dnsbl.invaluement.com',
        'ubl.lashback.com',
        'bl.mailspike.net',
        'ix.dnsbl.manitu.net',
        'no-more-funn.moensted.dk',
        'psbl.surriel.com',
        'spam.spamrats.com',
        'access.redhawk.org',
        'backscatter.spameatingmonkey.net',
        'bl.spameatingmonkey.net',
        'spam.dnsbl.sorbs.net',
        'bl.spamcannibal.org',
        'dnsrbl.swinog.ch',
        'truncate.gbudb.net',
        'db.wpbl.info',
    );
    return \@dnsbl_list;
}

sub check_spam {
    my ($self, $dnsbl) = @_;
    my $get_dnsbl_listing_result = get_dnsbl_listing( $self->ip->addr(), $dnsbl );
    return $get_dnsbl_listing_result;
}

sub run {
    my $self = shift;
    my %return;

    foreach my $dnsbl ( @{ $self->dnsbl } ) {
        my $result = $self->check_spam( $dnsbl );

        if( defined( $result ) ) {
            $return{$self->ip->addr()}{$dnsbl} = $result;
        }
    }

    return %return;

}

1;
