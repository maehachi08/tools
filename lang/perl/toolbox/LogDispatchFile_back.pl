#!/usr/local/bin/perl
# pachi
use strict;
use warnings;
use Log::Dispatch;

my $log_callback = sub {
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
};

my $log = Log::Dispatch->new(
    outputs => [
        # ファイル出力に関する設定
        [ 'File',
            min_level => 'debug',
            mode      => 'append',
            newline   => 1,
            filename  => 'test.log',
            callbacks => $log_callback ],

        # 標準出力に関する設定
        [ 'Screen',
            min_level => 'debug',
            newline   => 1,
            callbacks => $log_callback ],
    ],
);

$log->debug('debug message');
$log->info('info message');
$log->notice('notice message');
$log->emergency('emergency message');

exit 0;
