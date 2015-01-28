#!/usr/bin/env perl
# maehachi08
#
# 特定ディレクトリパスが存在しない場合に作成するという処理をmkpathで実装するテストスクリプト
#
use strict;
use warnings;
use Path::Class qw/file dir/;

my $path = './mkpath_dir/test_01/test';
-d $path or dir($path)->mkpath or die $!;
