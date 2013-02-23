package Observer::Walker::SNMP;
use Moose;
use namespace::autoclean;

use Net::SNMP qw(oid_lex_sort);
use Config;

my %oids = (
    'SNMPv2-MIB::sysDescr.0'            => '1.3.6.1.2.1.1.1.0',
    'IF-MIB::ifIndex'                   => '1.3.6.1.2.1.2.2.1.1',
    'IF-MIB::ifDescr'                   => '1.3.6.1.2.1.2.2.1.2',
    'IF-MIB::ifType'                    => '1.3.6.1.2.1.2.2.1.3',
    'IF-MIB::ifSpeed'                   => '1.3.6.1.2.1.2.2.1.5',
    'IF-MIB::ifAdminStatus'             => '1.3.6.1.2.1.2.2.1.7',
    'IF-MIB::ifOperStatus'              => '1.3.6.1.2.1.2.2.1.8',
    'IF-MIB::ifName'                    => '1.3.6.1.2.1.31.1.1.1.1',
    'RFC1213-MIB::atIfIndex'            => '1.3.6.1.2.1.3.1.1.1',
    'RFC1213-MIB::atPhysAddress'        => '1.3.6.1.2.1.3.1.1.2',
    'IP-MIB::ipNetToMediaIfIndex'       => '1.3.6.1.2.1.4.22.1.1',
    'IP-MIB::ipNetToMediaPhysAddress'   => '1.3.6.1.2.1.4.22.1.2',
    'BRIDGE-MIB::dot1dBaseBridgeAddress'=> '1.3.6.1.2.1.17.1.1',
    'BRIDGE-MIB::dot1dBasePortIfIndex'  => '1.3.6.1.2.1.17.1.4.1.2',
    'BRIDGE-MIB::dot1dTpFdbAddress'     => '1.3.6.1.2.1.17.4.3.1.1',
    'BRIDGE-MIB::dot1dTpFdbPort'        => '1.3.6.1.2.1.17.4.3.1.2',
    'Q-BRIDGE::dot1qTpFdbAddress'       => '1.3.6.1.2.1.17.7.1.2.2.1.1',
    'Q-BRIDGE::dot1qTpFdbPort'          => '1.3.6.1.2.1.17.7.1.2.2.1.2',
    'ENTITY-MIB::entLogicalCommunity'   => '1.3.6.1.2.1.47.1.2.1.1.4',
);

my %IANAifType = (
    'ethernetCsmacd'    => 6,
    'adsl'              => 94,
    'sdsl'              => 96,
    'vdsl'              => 97,
    'gigabitEthernet'   => 117,
    'hdsl2'             => 168,
    'shdsl'             => 169,
    'adsl2'             => 230,
);


has config      => ( is => 'ro' );
has session     => ( is => 'rw' );
has error       => ( is => 'rw' );
has hostname    => ( is => 'rw' );

sub connect {
    my ( $self, $snmp_args ) = @_;

    $self->error(undef);

    my ($session, $error) = Net::SNMP->session( %{$snmp_args}, -version => '2c' );
    unless ($session) {
        $self->error("Session error. Connect to '".$snmp_args->{-hostname}."': $error");
        return undef;
    }
    $self->session($session);
    $self->hostname($snmp_args->{-hostname});

    return $self->session;
}

sub close {
    my ( $self ) = @_;

    $self->session->close;
    $self->session(undef);
    $self->hostname(undef);
}


sub MAC {
    my ( $self ) = @_;

    $self->error(undef);

    my $result = $self->session->get_request($oids{'BRIDGE-MIB::dot1dBaseBridgeAddress'}.'.0');
    unless (defined $result) {
        $self->error("[BRIDGE-MIB::dot1dBaseBridgeAddress] Request error: ".$self->session->error);
        return;
    }
    my $dev_mac = $result->{$oids{'BRIDGE-MIB::dot1dBaseBridgeAddress'}.'.0'};
    unless (defined $dev_mac) {
        $self->error("Device return undefined MAC-address");
        return;
    }
    $dev_mac =~ s/^0x(.*)/lc($1)/e;
    return $dev_mac;
}

sub device_name {
    my ( $self ) = @_;

    $self->error(undef);

    # Search DevName
    my $dev_name = undef;

    my $result = $self->session->get_request($oids{'SNMPv2-MIB::sysDescr.0'});
    unless (defined $result) {
        $self->error("[SNMPv2-MIB::sysDescr.0] Request error: ".$self->session->error);
        return;
    }

    my $desc = $result->{$oids{'SNMPv2-MIB::sysDescr.0'}};
    foreach my $dname (keys %{$self->config->{snmp_devices}}) {
        if (ref $self->config->{snmp_devices}->{$dname}->{match_exp}) {
            foreach (@{$self->config->{snmp_devices}->{$dname}->{match_exp}}) {
                if ( $desc =~ m|$_|m ) {
                    $dev_name = $dname;
                    last;
                }
            }
        } else {
            # КОСТЫЛЬ: какойто глюк проявился с делинком, когда код перенес в модуль
            $_ = $self->config->{snmp_devices}->{$dname}->{match_exp};
            if ( $desc =~ m|$_|m ) {
                $dev_name = $dname;
            }
        }
        last if defined $dev_name;
    }

    $self->error("Device name does not found in config file match :\"$desc\"")
        unless defined $dev_name;

    return $dev_name
}

sub ports {
    my ( $self, $dev_name ) = @_;

    $self->error(undef);

    my $result = $self->session->get_table($oids{'IF-MIB::ifIndex'});
    unless (defined $result) {
        $self->error("[IF-MIB::ifIndex] Request error: ".$self->session->error);
        return;
    }

    my @if_index;
    foreach (oid_lex_sort(keys(%{$result}))) {
        push(@if_index, $result->{$_});
    }

    $result = $self->session->get_table($oids{'IF-MIB::ifType'});
    unless (defined $result) {
        $self->error("[IF-MIB::ifType] Request error: ".$self->session->error);
        return;
    }

    my $ports = {};
    my $i = 1;
    foreach my $ifi (@if_index) {
        my $oid = $oids{'IF-MIB::ifType'}.'.'.$ifi;
        if (exists $result->{$oid}) {
            if (ref $self->config->{snmp_devices}->{$dev_name}->{ianaiftype}) {
                foreach (@{$self->config->{snmp_devices}->{$dev_name}->{ianaiftype}}) {
                    if ( $result->{$oid} == $IANAifType{$_} ) {
                        $ports->{$i++} = { ifIndex => $ifi, ifType => $_ };
                        last;
                    }
                }
            } else {
                if ( $result->{$oid} == $IANAifType{$self->config->{snmp_devices}->{$dev_name}->{ianaiftype}} ) {
                    $ports->{$i++} = { ifIndex => $ifi, ifType => $self->config->{snmp_devices}->{$dev_name}->{ianaiftype} };
                }
            }
        }
    }

    # Получаем статус портов
    return unless $self->ports_dynamic_status($ports);

    # Получаем имя, с начала пробуем короткое
    $result = $self->session->get_table($oids{'IF-MIB::ifName'});
    if (defined $result &&
        length($result->{$oids{'IF-MIB::ifName'}.'.'.$ports->{'1'}->{ifIndex}}) > 0) {
        $result = $self->session->get_table($oids{'IF-MIB::ifName'});
        foreach my $port (keys %{$ports}) {
            my $oid = $oids{'IF-MIB::ifName'}.'.'.$ports->{$port}->{ifIndex};
            if (exists $result->{$oid}) {
                $ports->{$port}->{ifName} = $result->{$oid};
            } else {
                $self->error("[IF-MIB::ifName] Port: ".$ports->{$port}->{ifIndex}.", Error: Undefined value");
                return;
            }
        }
    } else {
        $result = $self->session->get_table($oids{'IF-MIB::ifDescr'});
        unless (defined $result) {
            return;
        }
        foreach my $port (keys %{$ports}) {
            my $oid = $oids{'IF-MIB::ifDescr'}.'.'.$ports->{$port}->{ifIndex};
            if (exists $result->{$oid}) {
                $ports->{$port}->{ifName} = $result->{$oid};
            } else {
                $self->error("[IF-MIB::ifDescr] Port: ".$ports->{$port}->{ifIndex}.", Error: Undefined value");
                return;
            }
        }
    }

    return $ports;
}

sub ports_dynamic_status {
    my ( $self, $ports ) = @_;

    $self->error(undef);

    my $result = $self->session->get_table($oids{'IF-MIB::ifSpeed'});
    unless (defined $result) {
        $self->error("[IF-MIB::ifSpeed] Request error: ".$self->session->error);
        return 0;
    }
    foreach my $port (keys %{$ports}) {
        my $oid = $oids{'IF-MIB::ifSpeed'}.'.'.$ports->{$port}->{ifIndex};
        if (exists $result->{$oid}) {
            $ports->{$port}->{ifSpeed} = $result->{$oid};
        } else {
            $self->error("[IF-MIB::ifSpeed] Port: ".$ports->{$port}->{ifIndex}.", Error: Undefined value");
            return 0;
        }
    }

    $result = $self->session->get_table($oids{'IF-MIB::ifAdminStatus'});
    unless (defined $result) {
        $self->error("[IF-MIB::ifAdminStatus] Request error: ".$self->session->error);
        return 0;
    }
    foreach my $port (keys %{$ports}) {
        my $oid = $oids{'IF-MIB::ifAdminStatus'}.'.'.$ports->{$port}->{ifIndex};
        if (exists $result->{$oid}) {
            $ports->{$port}->{ifAdminStatus} = $result->{$oid};
        } else {
            $self->error("[IF-MIB::ifAdminStatus] Port: ".$ports->{$port}->{ifIndex}.", Error: Undefined value");
            return 0;
        }
    }

    $result = $self->session->get_table($oids{'IF-MIB::ifOperStatus'});
    unless (defined $result) {
        $self->error("[IF-MIB::ifOperStatus] Request error: ".$self->session->error);
        return 0;
    }
    foreach my $port (keys %{$ports}) {
        my $oid = $oids{'IF-MIB::ifOperStatus'}.'.'.$ports->{$port}->{ifIndex};
        if (exists $result->{$oid}) {
            # delete port from hash if value == notPresent(6)
            if ( $result->{$oid} == 6 ) {
                delete($ports->{$port});
            } else {
                $ports->{$port}->{ifOperStatus} = $result->{$oid};
            }
        } else {
            $self->error("[IF-MIB::ifOperStatus] Port: ".$ports->{$port}->{ifIndex}.", Error: Undefined value");
            return 0;
        }
    }

    return 1;
}

sub macs {
    my ( $self, $dev_name ) = @_;

    my $result;
    my $macs = {};

    $self->error(undef);

    if ($self->config->{snmp_devices}->{$dev_name}->{algorithm} eq 'Q-BRIDGE' ||
        $self->config->{snmp_devices}->{$dev_name}->{algorithm} eq 'Q-BRIDGE-IF' ) {

        $result = $self->session->get_table($oids{'Q-BRIDGE::dot1qTpFdbPort'});
        unless (defined $result) {
            $self->error("[Q-BRIDGE::dot1qTpFdbPort] Request error: ".$self->session->error);
            return;
        }
        foreach (keys(%{$result})) {
            my $port = $result->{$_};
            s/$oids{'Q-BRIDGE::dot1qTpFdbPort'}\.\d+\.(\d+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)/sprintf("%02x%02x%02x%02x%02x%02x",$1,$2,$3,$4,$5,$6)/e;
            push(@{$macs->{$port}}, $_);
        }

    } elsif ($self->config->{snmp_devices}->{$dev_name}->{algorithm} eq 'BRIDGE') {

        $result = $self->session->get_table($oids{'BRIDGE-MIB::dot1dTpFdbPort'});
        unless (defined $result) {
            $self->error("[BRIDGE-MIB::dot1dTpFdbPort] Request error: ".$self->session->error);
            return;
        }
        foreach (keys(%{$result})) {
            my $port = $result->{$_};
            s/$oids{'BRIDGE-MIB::dot1dTpFdbPort'}\.(\d+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)/sprintf("%02x%02x%02x%02x%02x%02x",$1,$2,$3,$4,$5,$6)/e;
            push(@{$macs->{$port}}, $_);
        }

    } elsif ($self->config->{snmp_devices}->{$dev_name}->{algorithm} eq 'BRIDGE-COMM') {

        $result = $self->session->get_table($oids{'ENTITY-MIB::entLogicalCommunity'});
        unless (defined $result) {
            $self->error("[ENTITY-MIB::entLogicalCommunity] Request error: ".$self->session->error);
            return;
        }
        foreach (keys(%{$result})){
            my $comm = $result->{$_};
            my ($session, $error) = Net::SNMP->session(
                    -hostname => $self->hostname,
                    -community => $comm,
                    -version => '2c' );
            unless ($session) {
                $comm =~ s/^.*\@/\@/;
                $self->error("Session error ".$self->hostname.$comm.": $error");
                return;
            }

            my $result2 = $session->get_table($oids{'BRIDGE-MIB::dot1dTpFdbPort'});
            unless (defined $result) { # Игнорируем ошибки
                $session->close;
                next;
            };

            foreach (keys(%{$result2})) {
                my $port = $result2->{$_};
                my $mac;
                s/$oids{'BRIDGE-MIB::dot1dTpFdbPort'}\.(\d+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)\.(\d+)/$mac=sprintf("%02x%02x%02x%02x%02x%02x",$1,$2,$3,$4,$5,$6)/e;
                push(@{$macs->{$port}}, $_) unless scalar(grep { $_ eq $mac } @{$macs->{$port}});
            }
            $session->close;
        }

    } else {
        $self->error("Not found 'algorithm' in config for '$dev_name'");
        return;
    }

    return $macs;
}


=head1 NAME

Observer::Walker::SNMP

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
