#!/usr/bin/env perl

BEGIN { $ENV{DBIC_TRACE} = 1 }
use strict;
use warnings;
use FindBin '$Bin';
use lib "$Bin/../lib";
use Config::JFDI;
use Observer::Walker::SNMP;

my $jfdi = Config::JFDI->new(name => "Observer", default => {
    snmp_devices => {
        '_TEST_PORT'        => { ianaiftype => [ qw/adsl ethernetCsmacd gigabitEthernet/ ] },
        '_TEST_BRIDGE'      => { algorithm  => 'BRIDGE' },
        '_TEST_Q-BRIDGE'    => { algorithm  => 'Q-BRIDGE' },
        '_TEST_Q-BRIDGE-IF' => { algorithm  => 'Q-BRIDGE', algorithm_use => 'dot1dBasePortIfIndex' },
        '_TEST_BRIDGE-COMM' => { algorithm  => 'BRIDGE-COMM' },
    }
});
my $config = $jfdi->get;

my @algorithm = qw/BRIDGE Q-BRIDGE Q-BRIDGE-IF BRIDGE-COMM/;

my $snmp = Observer::Walker::SNMP->new( config  => $config );

foreach (@ARGV) {

    my ($community, $host) = split '@';

    print "Connect to hoso '$host'\n";
    if ($snmp->connect({ -hostname => $host, -community => $community })) {

        my $dev_name = $snmp->device_name || $snmp->error;
        print "Device Name: '$dev_name'\n";

        # Порты отрабатываются одинаково для всех алгоритмов
        my $ports = $snmp->ports('_TEST_PORT');
        foreach (sort { $a <=> $b } keys %{$ports}) {
            print "Port[$_]: ".$ports->{$_}->{ifIndex}
                ." '".$ports->{$_}->{ifName}
                ."' [".$ports->{$_}->{ifAdminStatus}
                .":".$ports->{$_}->{ifOperStatus}
                ."] type:".$ports->{$_}->{ifType}
                ." speed:".$ports->{$_}->{ifSpeed}."\n";
        }

        foreach my $alg (@algorithm) {
            print "Test algorithm: $alg\n";
            my $macs = $snmp->macs('_TEST_'.$alg, $ports);
            unless (defined $macs) {
                print "ERROR: ".$snmp->error."\n";
                next;
            }
            foreach (sort { $a <=> $b } keys %{$macs}) {
                print "P|IF[$_]: ".join(', ', @{$macs->{$_}})."\n";
            }
        }
        $snmp->close;
    } else {
        print "ERROR: ".$snmp->error."\n";
    }
}
