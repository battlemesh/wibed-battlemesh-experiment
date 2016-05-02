#!/bin/sh

### Hacky implementation of:
### https://docs.google.com/document/d/1LJZsittrwck1FNQaxYI_ezrLIA_PdhwYO56kvYeQRBc/

dev=$(uci get wbm.network.primary_dev)
mac=$(cat /sys/class/net/$dev/address)
halfmac=$(echo $mac | cut -d : -f 4-6 | tr -d :)
henningID=$(grep -m 1 $halfmac /etc/wbm/nodelist.txt | cut -f 2)

uci set wbm.network.ipv4_net="172.17.$henningID.1/24"
uci commit wbm

# Don't announce a default gateway, but push a static route to clients
uci set dhcp.lan.dhcp_option="3 121,172.17.0.0/16,172.17.$henningID.1"
uci commit dhcp


