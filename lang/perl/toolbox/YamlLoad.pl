#!/usr/local/bin/perl
use strict;
use warnings;
use YAML;

my $yaml = YAML::Load(join '', <DATA> );

print YAML::Dump($yaml);


__DATA__
---
user_name:
  - pachi
  - hoge
  - moge

pachi: tokyo
hoge: kyoto
moge: osaka
