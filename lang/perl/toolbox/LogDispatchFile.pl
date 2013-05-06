#!/usr/local/bin/perl
# pachi
use strict;
use warnings;
use Log::Dispatch;
use Log::Dispatch::Screen::Color;

my $log_callback = sub {
                 my %args = @_;
                 my ($pkg,$file,$line);
                 my $caller = 0;

                 while ( ($pkg,$file,$line) = caller($caller) ) {
                     last if $pkg !~ m!^Log::Dispatch!;
                     $caller++;
                 }

                 my @time = localtime;
                 my $monname = ("Jan", "Feb", "Mar", "Apr", "May", "Jun",
                   "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")[$time[4] - 1];

                 #sprintf "%04d-%02d-%02dT%02d:%02d:%02d [%s] %s at %s line %d.",
                 sprintf "$monname %04d at %s line %d.",
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
#        [ 'Screen',
#            min_level => 'debug',
#            newline   => 1,
#            callbacks => $log_callback ],
#    ],
        [ 'Screen::Color',
            min_level => 'debug',
            newline   => 1,
            #callbacks => $log_callback,
            stderr    => 1,
            format    => '[%d] [%p] %m at %F line %L%n',
            color     => {
                info  => {
                    text => 'red',
                },
                error   => {
                    background => 'red',
                },
                alert   => {
                    text       => 'red',
                    background => 'white',
                },
                warning => {
                    text       => 'red',
                    background => 'white',
                    bold       => 1,
                },
            } ]
    ],

);
$log->log( level => 'error', message => "I like wasabi!\n" );
$log->debug('debug message');
$log->info('info message');
$log->notice('notice message');
$log->emergency('emergency message');

exit 0;
