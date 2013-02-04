#!/usr/bin/perl
use strict;
use warnings;
use NetAddr::IP;

my $ip = new NetAddr::IP '192.168.1.123';

print "$ip\n";

print $ip->addr();

exit 0;
