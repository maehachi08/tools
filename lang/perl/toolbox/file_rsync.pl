#!/usr/bin/env perl
use strict;
use warnings;
use YAML;
use File::Rsync;

# When you want to debug, you should exec "export SCRIPT_DEBUG=1".
my $debug = $ENV{SCRIPT_DEBUG} ? 1 : 0;

main();
exit 0;

sub main {
    my $stuff = YAML::Load(join '', <DATA> );

    push my @backup_names, keys %{ $stuff->{backup} };
    foreach my $backup_name ( @backup_names ) {
        printf "Start rsync job $backup_name\n" if $debug;
        rsync( $stuff, $backup_name );
    }

    print YAML::Dump($stuff) if $debug;
}


sub rsync {
    my ($stuff, $backup_name) = @_;
    my $rsync = construct_rsync( $stuff, $backup_name );
    $rsync->exec;
    print finalize_rsync( $rsync ) . "\n";
}


sub construct_rsync {
    my ($stuff, $backup_name) = @_;
    my $src     = $stuff->{backup}->{$backup_name}->{args}->{src};
    my $dest    = $stuff->{backup}->{$backup_name}->{args}->{dest};
    my $timeout = $stuff->{backup}->{$backup_name}->{args}->{timeout};

    my $rsync = File::Rsync->new( {
        src      => $src,
        dest     => $dest,
        bwlimit  => 7680,
        timeout  => $timeout,
        archive  => 1,
        delete   => 1,
        stats    => 1,
        verbose  => 0,
    } );

    print YAML::Dump($rsync) if $debug;
    return $rsync;
}


sub finalize_rsync {
    my $rsync = shift;
    my $stats = stats( $rsync->out );
    my $error = join ', ', $rsync->err;

    my $message;
    if ( $stats ) {
        $message = $error ? join( ", ", $stats, $error) : $stats;
    } else {
        $message = $error || 'Unknown errors occured';
    }

    return $message;
}


sub stats {
    my @out = @_;
    return unless @out;

    my @stats;
    foreach my $item (
        'Total file size',
        'Number of files transferred',
        'Total bytes received',
    ) {
      my ($val) = grep $_ =~ qr/$item/, @out;
      push @stats, $val if $val;
    }

    my $speed = $out[-2];
    $speed =~ s{.*[ ]([\d.]+[ ]bytes/sec)}{Average speed: $1}sx;
    push @stats, $speed if $speed;

    chomp @stats;
    return join ", ", @stats;
}




exit 1;


__DATA__
---

backup:
  application:
    args:
      src     : www.maepachi.com:/var/www/rails/infinitewall
      dest    : /var/backup/app/rails/
      timeout : 180

  
