#!/usr/bin/env perl
use strict;
use warnings;
use Getopt::Long;
use Net::OpenSSH;

# When you want to debug, you should exec "export SCRIPT_DEBUG=1".
my $debug = $ENV{SCRIPT_DEBUG} ? 1 : 0;

my $exec;
my $host;

if ($#ARGV == -1) { pod2usage(-verbose => 2) };
GetOptions (
    'exec=s'  => \$exec,
    'host=s'  => \$host,
) or pod2usage(-verbose => 2);

main();

sub main {
    my $ssh    = construct_ssh( $host );
    my $return = exec_ssh( $ssh, $exec );
}

sub construct_ssh {
    my $host = shift;

    my $ssh = Net::OpenSSH->new( $host );
    $ssh->error and
    die "Couldn't establish SSH connection: ". $ssh->error;

    return $ssh;
}

sub exec_ssh {
    my ( $ssh, $exec ) = @_;

    $ssh->system( $exec ) or
        die "remote command failed: " . $ssh->error;
    return $ssh;
}

exit 1;

