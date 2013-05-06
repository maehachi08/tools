#!/usr/bin/perl
use strict;
use warnings;
use lib 'lib/';
use MoosexGetopt;

my $cmd = MoosexGetopt->new_with_options();

my ($cmd) = @_;

my $arg1 = $cmd->arg1;

printf "$arg1\n";

exit 0;
