#!/bin/sh

### Hacky implementation of:
### https://docs.google.com/document/d/1LJZsittrwck1FNQaxYI_ezrLIA_PdhwYO56kvYeQRBc/

dev=$(uci get wbm.network.primary_dev)
mac=$(cat /sys/class/net/$dev/address)
halfmac=$(echo $mac | cut -d : -f 4-6 | tr -d :)
henningID=$(grep -m 1 $halfmac /etc/wbm/nodelist.txt | cut -f 2)
[ -z "$henningID" ] && henningID=99

uci set wbm.network.ipv4_net="172.17.$henningID.1P/32"
uci set wbm.network.ipv6_net="fcba:$henningID::1P/128"

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
uci set network.wiredtests.ip6addr="fcba:$henningID::1/64"

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

### olsrd6 was not considered at all at battlemeshv6 setup scripts, so we're making a hacky dump of the config
uci import olsrd6 <<EOF
config olsrd
        option IpVersion '6'

config LoadPlugin
        option library 'olsrd_arprefresh.so.0.1'

config LoadPlugin
        option library 'olsrd_txtinfo.so.0.1'
        option accept '::'
        option port '2006'

config Interface
        option interface 'lan_olsr'

config Interface
        option interface 'wbm1_olsr'

config Hna6
        option netaddr 'fcba:$henningID::'
        option netmask '64'
EOF

uci commit
