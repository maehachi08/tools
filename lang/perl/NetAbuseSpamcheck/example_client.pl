#!/usr/local/bin/perl
use strict;
use warnings;
use lib 'lib/';
use Net::Abuse::Spamcheck;
use Data::Printer;

my @ips = ( '219.136.216.139','219.136.216.140' );

foreach my $ip ( @ips ) {
    printf "$ip\n";
    my $object = Net::Abuse::Spamcheck->new( ip => $ip );
    my %return = $object->run;
    print p( %return ) . "\n";
}

exit 0;
