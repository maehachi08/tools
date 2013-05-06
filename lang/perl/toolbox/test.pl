#!/usr/local/bin/perl
use strict;
use warnings;

my $debug = 1;
my $exist;

if( defined( $debug ) ) {
    $exist = 1;
} else {
    printf "hoge\n";
}

if( defined( $exist ) ) {
    printf "exist variable ok\n";
} else {
    printf "exist variable ng\n";
}
