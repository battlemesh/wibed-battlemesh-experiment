#!/bin/sh

#set -x

#ACTIONS are: add prepare clean?
#example: cjdns.sh <action> <virtual_if> <actual_if> <IPv4/16> <IPv6/64>

ACTION=$1
LOGICAL_INTERFACE=$2

# these aren't used by cjdns
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5

clean () {
  uci revert cjdns
  rm /etc/config/cjdns
}

prepare () {
  clean
  touch /etc/config/cjdns
  cjdroute --genconf | cjdroute --cleanconf | cjdrouteconf set

  uci set network.lan_cjdns.ip6addr=$(uci get cjdns.cjdns.ipv6)
}

add () {
  SECTION=$(uci add cjdns eth_interface)
  uci set cjdns.$SECTION.bind=$LOGICAL_INTERFACE
  uci set cjdns.$SECTION.beacon=2

  uci commit cjdns
}

start () {
  /etc/init.d/cjdns start 2> /dev/null
}

stop () {
  /etc/init.d/cjdns stop 2> /dev/null
  killall -KILL cjdns 2> /dev/null
}

$ACTION
