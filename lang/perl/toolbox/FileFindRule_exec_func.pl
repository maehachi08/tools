#!/usr/bin/perl
use strict;
use warnings;
use File::Find::Rule;

my @basenames;
my $find_object = File::Find::Rule->file()
                                  ->name( '*' )
                                  ->exec(
                                      sub {
                                          my ( $shortname, $path, $fullname ) = @_;
                                          my $basename = get_basename( $fullname );
                                          push @basenames, $basename;
                                      } )
                                  ->in( '/root/git' );

sub get_basename {
    my $filename = shift;
    return File::Basename::basename( $filename );
}

print( map{ $_ . "\n" } @basenames );
