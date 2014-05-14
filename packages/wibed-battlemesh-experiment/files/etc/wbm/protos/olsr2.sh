#!/bin/sh

#set -x

#ACTIONS are: add prepare clean?
# example: $0 <action> <virtual_if> <actual_if> <IPv4/16> <IPv6/64>

# olsr.sh prepare
# olsr.sh add wlan wlan0
# olsr.sh add lan eth0.1

ACTION=$1
LOGICAL_INTERFACE=$2
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5

store_neigh_stats()
{
# output should look like this
# and will be used to plot some .dot-files for visualization
#
# $myhostname $neighmac_or_ip    $iface  $quali $rx/tx-packets/bytes   $minstrel_filename
# wbm-8cd9    11:22:33:44:55:66  eth0.1  4321   123 435 723876 7632465 /tmp/minstrel.$uptimestamp

# fdba:15::/32
    echo
}

prepare() {
    echo >  /etc/olsrd2.conf "[ff_dat_metric]"
    echo >> /etc/olsrd2.conf "    raw_filename   /save/olsrd2_metricdata.txt"
    echo >> /etc/olsrd2.conf "    raw_maxpackets 50000"
    echo >> /etc/olsrd2.conf "    raw_maxtime    3600"
    echo >> /etc/olsrd2.conf "    raw_start      true"
    echo >> /etc/olsrd2.conf ""
}

add() {
    echo  >> /etc/olsrd2.conf "[interface=${REAL_INTERFACE}]"
}

start () {
    /etc/init.d/olsrd2 start
}

stop () {
    /etc/init.d/olsrd2 stop
    killall -9 olsrd2 2>/dev/null
}

$ACTION
