#!/bin/sh

### Hacky implementation of:
### https://docs.google.com/document/d/1LJZsittrwck1FNQaxYI_ezrLIA_PdhwYO56kvYeQRBc/

dev=$(uci get wbm.network.primary_dev)
mac=$(cat /sys/class/net/$dev/address)
halfmac=$(echo $mac | cut -d : -f 4-6 | tr -d :)
henningID=$(grep -m 1 $halfmac /etc/wbm/nodelist.txt | cut -f 2)

uci set wbm.network.ipv4_net="172.17.$henningID.201/24"

### Leave only one physical port on eth0.1, and put the rest into eth0.3
### eth0.1 will be left bridged with the mgmt network
uci set network.@switch_vlan[0].ports='0t 2'

uci -q add network switch_vlan
uci set network.@switch_vlan[-1].device='switch0'
uci set network.@switch_vlan[-1].vlan='3'
uci set network.@switch_vlan[-1].ports='0t 3 4 5'

### use eth0.2 for "lan" since protocol vlans will be built on top of that
uci del network.wan.ifname
uci del network.wan6.ifname

uci set network.lan=interface
uci set network.lan.ifname="eth0.2"
uci set network.lan.proto="static"

### use eth0.3 for "laptops"
uci set network.wiredtests=interface
uci set network.wiredtests.ifname="eth0.3"
uci set network.wiredtests.proto="static"
uci set network.wiredtests.ipaddr="172.17.$henningID.1/24"
uci set network.wiredtests.netmask="255.0.0.0"

uci set dhcp.wiredtests=dhcp
uci set dhcp.wiredtests.interface='wiredtests'
uci set dhcp.wiredtests.start='100'
uci set dhcp.wiredtests.limit='150'
uci set dhcp.wiredtests.leasetime='1h'
uci set dhcp.wiredtests.dhcpv6='server'
uci set dhcp.wiredtests.ra='server'
### don't announce a default gateway (don't break laptops internet), but push a static route
uci set dhcp.wiredtests.dhcp_option="3 121,172.17.0.0/16,172.17.$henningID.1"

uci set wibed.location.testbed='BattleMeshv9-Porto'

uci commit
