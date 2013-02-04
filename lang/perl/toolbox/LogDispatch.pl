#!/usr/local/bin/perl
use strict;
use warnings;
use Log::Dispatch;

my $log = Log::Dispatch->new(
    outputs => [[
        'Screen',
        min_level => 'debug',
        stderr    => 1,
        newline   => 1,
        callbacks => sub {
            my %args = @_;
            my ($pkg,$file,$line);
            my $caller = 0;
            while ( ($pkg,$file,$line) = caller($caller) ) {
                last if $pkg !~ m!^Log::Dispatch!;
                $caller++;
            }
            my @time = localtime;
            sprintf "%04d-%02d-%02dT%02d:%02d:%02d [%s] %s at %s line %d.",
                $time[5]+1900, $time[4]+1, @time[3,2,1,0],
                $args{level}, $args{message},
                $file, $line;
            }
    ]]
);

$log->debug('debug message');
$log->info('info message');
$log->notice('notice message');
$log->emergency('emergency message');

exit 0;
