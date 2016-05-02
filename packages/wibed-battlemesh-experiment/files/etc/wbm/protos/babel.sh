#!/bin/sh

#set -x

#ACTIONS are: add prepare clean?
# example: $0 <action> <virtual_if> <actual_if> <IPv4/16> <IPv6/64>


ACTION=$1
LOGICAL_INTERFACE=$2
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5

clean () {
  uci revert babeld
  rm /etc/config/babeld
  touch /etc/config/babeld
}

prepare () {
  clean

  touch /etc/config/babeld

  uci import babeld <<EOF

config general
  option 'log_file' '/var/log/babeld.log'
  option 'ipv6_subtrees' 'true'
  option 'diversity' '3'

config filter
  option ignore 'false'
  option type 'redistribute'
  option local '1'
  option action 'deny'

config interface
  option 'enable_timestamps' 'true'

config filter
  option 'type' 'redistribute'
  option 'action' 'allow'

config filter
  option 'ignore' 'true'
  option 'type' 'redistribute'
  option 'local'  'true'

EOF
}

add () {
  uci set babeld.${LOGICAL_INTERFACE}=interface
  uci set babeld.${LOGICAL_INTERFACE}.ifname=${LOGICAL_INTERFACE}

  uci add babeld filter
  uci set babeld.@filter[-1].ignore=false
  uci set babeld.@filter[-1].type=redistribute
  uci set babeld.@filter[-1].ip="${IPV6}"

  uci commit babeld
}

start () {
  /etc/init.d/babeld start
}

stop () {
  /etc/init.d/babeld stop
  killall -9 babeld 2>/dev/null
}

$ACTION
