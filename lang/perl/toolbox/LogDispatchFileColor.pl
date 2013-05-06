#!/usr/local/bin/perl
# pachi
use strict;
use warnings;
use YAML();
use Log::Dispatch;
use Log::Dispatch::Screen::Color;
use Log::Dispatch::Config;
use Log::Dispatch::Configurator::YAML;

my $config = Log::Dispatch::Configurator::YAML->new('log.yaml');
Log::Dispatch::Config->configure($config);
my $log = Log::Dispatch::Config->instance;

$log->log( level => 'error', message => "I like wasabi!\n" );
$log->debug('debug message');
$log->info('info message');
$log->notice('notice message');
$log->emergency('emergency message');

exit 0;
