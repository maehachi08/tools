#!/usr/local/bin/perl
use strict;
use warnings;
use lib 'lib/';
use Net::Abuse::Spamcheck;
use Data::Printer;

# When you want to debug, you should exec "export SCRIPT_DEBUG=1".
my $debug = $ENV{SCRIPT_DEBUG} ? 1 : 0;

my @ips = ( '219.136.216.139','219.136.216.140' );

foreach my $ip ( @ips ) {
    printf "$ip\n" if $debug;

    my $object = Net::Abuse::Spamcheck->new( ip => $ip );
    my %return = $object->run;

    print p( %return ) . "\n" if $debug;

    if ( defined( $return{$ip}  ) ) {
      printf "$ip is black\n";
    } else {
      printf "$ip is not black\n";
    }
}

exit 0;
