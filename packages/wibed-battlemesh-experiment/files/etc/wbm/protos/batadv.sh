#!/bin/sh

ACTION=$1
LOGICAL_INTERFACE=$2
REAL_INTERFACE=$3
IPV4=$4
IPV6=$5
R1=$6
R2=$7

dev=$(uci get wbm.network.primary_dev)
mac=$(cat /sys/class/net/$dev/address)
halfmac=$(echo $mac | cut -d : -f 4-6 | tr -d :)
henningID=$(grep -m 1 $halfmac /etc/wbm/nodelist.txt | cut -f 2)
[ -z "$henningID" ] && henningID=99

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
  uci set network.bat1.routing_algo='BATMAN_V'
  uci set network.wbm1_batadv.routing_algo='BATMAN_V'
  
  uci set network.batadv_mesh=interface
  uci set network.batadv_mesh.type=bridge
  uci set network.batadv_mesh.proto=static
  uci add_list network.batadv_mesh.ifname=bat1
  uci set network.batadv_mesh.disabled=1
  uci commit network
}

add () {
  if [ "$(uci -q get network.bat1.macaddr)" == "" ] ; then
    uci set network.batadv_mesh.macaddr="$(printf '02:ba:ff:%02x:%02x:01' $R1 $R2)"
  fi
  if [ "$(uci -q get network.bat1.ip6addr)" == "" ] ; then
    uci set network.batadv_mesh.ip6addr="$(printf '2001:db8:$henningID::%02x%02x/64' $R1 $R2)"
  fi
  if [ "$(uci -q get network.bat1.ipaddr)" == "" ] ; then
    uci set network.batadv_mesh.ipaddr="$(ipv4_addr)"
    uci set network.batadv_mesh.netmask="$(ipv4_netmask)"
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
