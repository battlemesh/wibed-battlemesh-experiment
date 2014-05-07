#!/bin/sh

ACTION=$1
LOGICAL_INTERFACE=$2
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5
R1=$6
R2=$7

ipv4_addr () {
  echo ${IPV4%%/*}
}

ipv4_netmask () {
  echo ${IPV4##*/}
}

clean () {
  true  
}

prepare () {
  uci set batman-adv.bat1=mesh
  uci set batman-adv.bat1.bridge_loop_avoidance=1
  uci commit batman-adv

  uci set network.bat1=interface
  uci set network.bat1.ifname=bat1
  uci set network.bat1.proto=static
  uci set network.bat1.ip6addr=""
  uci set network.bat1.ipaddr=""
  uci set network.bat1.netmask=""
  uci set network.bat1.mtu=1500
  uci commit network
}

add () {
  if [ "$(uci -q get network.bat1.macaddr)" == "" ] ; then
    uci set network.bat1.macaddr="$(printf '02:ba:ff:%02x:%02x:01' $R1 $R2)"
  fi
  if [ "$(uci -q get network.bat1.ip6addr)" == "" ] ; then
    uci set network.bat1.ip6addr="$(printf 'fdbb::%02x%02x/64' $R1 $R2)"
  fi
  if [ "$(uci -q get network.bat1.ipaddr)" == "" ] ; then
    uci set network.bat1.ipaddr="$(ipv4_addr)"
    uci set network.bat1.netmask="$(ipv4_netmask)"
  fi
  uci set network.${LOGICAL_INTERFACE}=interface
  uci set network.${LOGICAL_INTERFACE}.proto=batadv
  uci set network.${LOGICAL_INTERFACE}.mesh=bat1
  uci set network.${LOGICAL_INTERFACE}.mtu=1528
  uci commit network
}

#TO-BE-DONE
start () {
	true
}

stop () {
	true
}

$ACTION
