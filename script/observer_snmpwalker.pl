#!/usr/bin/env perl

use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";

use File::Basename;
use Sys::Syslog qw(:standard);
use Getopt::Long;

BEGIN {
    $ENV{CATALYST_DEBUG} = 0;
    $ENV{DBIC_TRACE} = 1;
}

use Observer::Schema;
use Config::JFDI;
use Observer::Walker;


my ($help, $version, $foreground);
my $pidfile     = '/var/run/observer_snmpwalker.pid';
my $loop_method = 'auto';
my $loops       = 1;

GetOptions(
    'help|h'            => \$help,
    'version|v'         => \$version,
    'foreground|f'      => \$foreground,
    'pidfile|p:s'       => \$pidfile,
    'loop_method|m:s'   => \$loop_method,
    'loops|l:i'         => \$loops,
);

if ($help) {
    print <<"EOF";

Usage:  observer_snmpwalker.pl [OPTIONS]

  -f, --foreground   Force snmpwalker to run as a foreground process.
  -p, --pidfile file Specifies the file to write the process ID to
                     (default is /var/run/observer_snmpwalker.pid).
  -m, --loop_method  You can change the process method between fork and
                     thread. (default auto) Ignored if foreground.
  -l, --loops num    Number of parallel executed events (default is 1).
  -v, --version      Print version.
  -h, --help         Display this usage message.

EOF
    exit;
}

if ($version) {
    print "observer_snmpwalker.pl version ".$Observer::Walker::VERSION."\n";
    exit;
}

unless ( $loop_method =~ m/^(auto|fork|thread)$/i ) {
    print "Wrong process method '$loop_method'!\nUse with option -m fork or thread\n";
    exit;
}

use POSIX qw(locale_h);
setlocale(LC_ALL, "C");

openlog(basename($0), "ndelay,pid", "daemon");
#err warning notice info debug

my $quit_main = 0;
my $reload;
$SIG{INT} = $SIG{TERM} = sub { $quit_main = 1; };
$SIG{HUP} = sub { $reload = 1; };
$SIG{STOP} = $SIG{USR1} = sub {}; # Some system not support "IGNORE"

unless ($foreground) {
    my $pid = fork;
    exit if $pid;

    unless (defined $pid) {
        syslog('err', 'Couldn\'t fork: %m');
        die "Couldn't fork: $!";
    }

    unless (open(PID,">".$pidfile)) {
        syslog('err', 'Can\'t create pid file \'%s\': %m', $pidfile);
        die "Can't create pid file '".$pidfile."': $!";
    }
    print PID "$$\n";
    close(PID);
}

my $jfdi = Config::JFDI->new(name => "Observer");
my $config = $jfdi->get;

my $can_use_threads = 0;
if ( $loop_method =~ m/^(auto|thread)$/i ) {
    $can_use_threads = eval 'use threads; 1';
}

do {
    my @threads;
    $reload = 0;

    if ($foreground) {

        syslog('info', "Do processing foreground");

        loop($$, 0, $config);

    } elsif ($can_use_threads) {

        syslog('info', "Do processing using threads");

        use threads;

        for ( my $count = 1; $count <= $loops; $count++) {
            my $t = async {
                loop($$, $count, $config);
            };
            $t->detach;
            push(@threads, $t);
        }
        sleep 1 until $quit_main || $reload;
        syslog('info', "Restart program") if $reload;

        foreach (@threads) {
            $_->kill('USR1');
        }
        my $wait_stop = 1;
        while ($wait_stop) {
            $wait_stop = 0;
            foreach (@threads) {
                if ($_->is_running) {
                    $wait_stop = 1;
                    sleep 1;
                    last;
                }
            }
        }

    } else {

        syslog('info', "Do it without using threads");

        my $ppid = $$;
        for ( my $count = 1; $count <= $loops; $count++) {
            my $pid = fork;
            if ($pid) {             # parent
                push(@threads, $pid);
            } elsif ($pid == 0) {   # child
                loop($ppid, $count, $config);
                closelog;
                exit 0;
            } else {
                syslog('err', 'Couldn\'t fork: %m');
                die "Couldn't fork: $!";
            }
        }
        sleep 1 until $quit_main || $reload;
        syslog('info', "Restart program") if $reload;

        kill 'USR1', @threads;
        foreach (@threads) {
            waitpid($_, 0);
        }
    }

    $config = $jfdi->reload if $reload;

} while $reload;

syslog('info', "End of main program");

closelog;
unlink $pidfile unless $foreground;
exit 0;

sub loop {
    my ( $ppid, $loopid, $config ) = @_;
    my $quit_loop = 0;
    my $i = 0;

    local $SIG{TERM} = sub {}; # Some systems not support "IGNORE"
    local $SIG{INT} = $SIG{USR1} = sub { $quit_loop = 1; };

    my $schema = Observer::Schema->connect( $config->{'Model::DB'}->{connect_info} );
    unless ($schema) {
        syslog('err', 'Failed to connect to database: %m');
        return;
    }

    my $walker = Observer::Walker->new(
            config  => $config,
            schema  => $schema,
            procid  => $ppid,
            loopid  => $loopid,
    );

    until ($quit_loop) {
        eval {
            sleep $config->{'idle_timeout'}
                if $walker->do_walk;
        };
        if ($@) {
            $@ =~ s/(line\s\d+(.*?)\.).*$/$1/g;
            syslog('warning', "Process $loopid aborted by error: $@");
            sleep $config->{'idle_timeout'}
                unless $quit_loop;
        }
    }
    $walker->close;

    syslog('info', "Done process $loopid");
}
