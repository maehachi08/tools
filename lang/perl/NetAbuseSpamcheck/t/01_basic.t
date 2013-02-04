# t/oo_compile.t
use strict;
use Test::More;
use Net::Abuse::Spamcheck;

my $object = Net::Abuse::Spamcheck->new( ip => "8.8.8.8" );
ok( defined $object && $object->isa('Net::Abuse::Spamcheck') );

my %return = $object->run;
ok %return;

done_testing;
