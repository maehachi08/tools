#!/usr/bin/perl
use strict;
use warnings;
use Pod::Usage;
use Getopt::Long;

# GetOptionsブロックで指定する変数は事前定義しておく
my $name;
my $age;

# 引数チェック
if ($#ARGV == -1) { pod2usage(-verbose => 2) };

# nameオプションはstring、ageオプションはinteger
# それぞれの値をリファレンスへ渡す
GetOptions (
  'name=s' => \$name,
  'age=i'  => \$age,
) or pod2usage(-verbose => 2);

printf "Your name is $name\n";
printf "Your age is $age\n";

__END__

=head1 NAME

    GetoptLong.pl

=head1 SYNOPSIS

  $ perl GetoptLong.pl --name pachi --age 28

=head1 DESCRIPTION

  This script is usage of Getopt::Long module

=head1 OPTIONS

  When you don't put arguments , script show POD only.

  --name  :your name
  --age   :your age

=head1 AUTHOR

  kazunori maehata (@maehachi08)

=cut
