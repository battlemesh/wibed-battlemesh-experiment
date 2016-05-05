#!/bin/sh

#set -x

#ACTIONS are: add prepare clean?
#example: bmx7.sh <action> <virtual_if> <actual_if> <IPv4/16> <IPv6/64>

ACTION=$1
LOGICAL_INTERFACE=$2
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5

clean () {
  uci revert bmx7
  rm /etc/config/bmx7
  touch /etc/config/bmx7
}

prepare () {
  rm -f /etc/config/bmx7
  touch /etc/config/bmx7

  uci import bmx7 <<EOF
config 'plugin'
        option 'plugin' 'bmx7_config.so'

config 'plugin'
        option 'plugin' 'bmx7_iwinfo.so'

config 'plugin'
        option 'plugin' 'bmx7_json.so'

config 'plugin'
        option 'plugin' 'bmx7_tun.so'

config 'plugin'
        option 'plugin' 'bmx7_topology.so'

config 'tunDev' 'tunDev'
        option 'tunDev' 'default'

config 'tunOut'
        option 'tunOut' 'ip4'
        option 'network' '172.16.0.0/12'

config 'tunOut'
        option 'tunOut' 'ip6'
        option 'network' '2001:db8::/32'
EOF

}

add () {
  uci set bmx7.${LOGICAL_INTERFACE}=dev
  uci set bmx7.${LOGICAL_INTERFACE}.dev=${REAL_INTERFACE}
  # if it's a wifi interface, force linklayer detection
  if ! [ "${LOGICAL_INTERFACE##wbm}" == "${LOGICAL_INTERFACE}" ] ; then
    uci set bmx7.${LOGICAL_INTERFACE}.linklayer=2
  fi

  if ! uci -q get bmx7.tunDev.tun4Address > /dev/null ; then
    # use a different ip ending (177) to avoid conflicts with interface-specific ips
    uci set bmx7.tunDev.tun4Address="$( echo ${IPV4} | sed s/"\.\w\+\/.*"/".177\/24"/ )"
    uci set bmx7.tunDev.tun6Address="$( echo ${IPV6} | sed s/"\:\w\+\/.*"/":177\/64"/ )"
  fi

  uci commit bmx7
}

stop () {
  /etc/init.d/bmx7 stop
  sleep 1
  killall -9 bmx7 2>/dev/null
}

start () {
  /etc/init.d/bmx7 start
}

$ACTION
