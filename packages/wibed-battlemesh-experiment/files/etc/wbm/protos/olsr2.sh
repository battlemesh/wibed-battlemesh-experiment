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
  uci revert olsrd2
  rm /etc/config/olsrd2
  touch /etc/config/olsrd2

  uci -q add olsrd2 global
  uci set olsrd2.@global[-1]=global
  uci set olsrd2.@global[-1].pidfile='/var/run/olsrd2.pid'
  uci set olsrd2.@global[-1].lockfile='/var/lock/olsrd2'

  uci -q add olsrd2 log
  uci set olsrd2.@log[-1]=log
  uci set olsrd2.@log[-1].syslog='true'
  uci set olsrd2.@log[-1].stderr='true'

  uci commit olsrd2

}

add() {
  uci -q add olsrd2 interface
  uci set olsrd2.@interface[-1]=interface
  uci set olsrd2.@interface[-1].ifname=${LOGICAL_INTERFACE}

  uci -q add olsrd2 interface
  uci set olsrd2.@interface[1]=interface
  uci set olsrd2.@interface[1].ifname='wan' 'lan'
  uci set olsrd2.@interface[1].rx_bitrate='100M'

  uci commit olsrd2
}

start () {
    /etc/init.d/olsrd2 start
}

stop () {
    /etc/init.d/olsrd2 stop
    killall -9 olsrd2 2>/dev/null
}

$ACTION
