#!/usr/bin/perl
use strict;
use warnings;

# When you want to debug, you should exec "export SCRIPT_DEBUG=1".
my $debug = $ENV{SCRIPT_DEBUG} ? 1 : 0;

printf "デバッグ時のみ出力します\n" if $debug;
exit 0;
