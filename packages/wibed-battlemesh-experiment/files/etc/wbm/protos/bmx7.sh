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

  uci set bmx7.general=bmx7
# uci set bmx7.general.ipAutoPrefix="::/0"
# uci set bmx7.general.globalPrefix="fd11::/48"

  # Prevent syslog messages by default
  uci set bmx7.general.syslog=0

  # Some tunning for the WBM scenario
  uci set bmx7.general.dbgMuteTimeout=1000000
# uci set bmx7.general.purgeTimeout=70000
# uci set bmx7.general.linkPurgeTimeout=20000
# uci set bmx7.general.dadTimeout=15000

  # Enable bmx7 uci config plugin
  uci set bmx7.config=plugin
  uci set bmx7.config.plugin=bmx7_config.so

  # Enable de JSON plugin to get bmx7 information in json format
#  uci set bmx7.json=plugin
#  uci set bmx7.json.plugin=bmx7_json.so

  # Disable ThrowRules because they are broken in IPv6 with current Linux Kernel
  uci set bmx7.ipVersion=ipVersion
  uci set bmx7.ipVersion.ipVersion=6
  uci set bmx7.ipVersion.throwRules=0


  # Smart gateway search for IPV4

  # Search for any announcement of 10/8 in the mesh cloud
  #uci set bmx7.mesh=tunOut
  #uci set bmx7.mesh.tunOut=mesh
  #uci set bmx7.mesh.network=10.0.0.0/8
  #uci set bmx7.mesh.minPrefixLen=24
  #uci set bmx7.mesh.maxPrefixLen=32

  # Search for internet in the mesh cloud
  #uci set bmx7.inet=tunOut
  #uci set bmx7.inet.tunOut=inet
  #uci set bmx7.inet.network=0.0.0.0/0
  #uci set bmx7.inet.minPrefixLen=0
  #uci set bmx7.inet.maxPrefixLen=0


# Smart gateway search for IPV6
  
  # Search for any IPv6 announcement in the mesh cloud
  #uci set bmx7.ipv6=tunOut
  #uci set bmx7.ipv6.tunOut=ipv6
  #uci set bmx7.ipv6.network=::/0

  uci commit bmx7
}

add () {
  uci set bmx7.${LOGICAL_INTERFACE}=dev
  uci set bmx7.${LOGICAL_INTERFACE}.dev=${REAL_INTERFACE}
  uci set bmx7.${LOGICAL_INTERFACE}.globalPrefix="$( echo ${IPV6} echo | sed s/"\/.*"/"\/128"/ )"

  # To enable IPv4

  #if uci -q get bmx7.general.tun4Address > /dev/null ; then
  #  uci set bmx7.tun_${LOGICAL_INTERFACE}=tunInNet
  #  uci set bmx7.tun_${LOGICAL_INTERFACE}.tunInNet="$( echo ${IPV4} echo | sed s/"\/.*"/"\/32"/ )"
  #  uci set bmx7.tun_${LOGICAL_INTERFACE}.bandwidth="128000000000"
  #else
  #  uci set bmx7.general.tun4Address="$( echo ${IPV4} echo | sed s/"\/.*"/"\/32"/ )"
  #fi

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
