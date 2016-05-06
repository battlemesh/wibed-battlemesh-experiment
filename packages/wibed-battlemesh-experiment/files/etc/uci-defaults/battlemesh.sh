#!/bin/sh

/usr/bin/wbm-config > /tmp/wbm-config.log 2>&1

### Disable all protocols by default (including batadv)
### and point them to the raw wifi interface (no vlans)
for proto in babel bmx7 olsr olsr2 batadv ; do
    uci set network.wbm1_$proto.ifname='@wbm1_base'
    uci set network.wbm1_$proto.disabled=1
    uci set network.lan_$proto.disabled=1
done
for daemon in babeld olsrd olsrd6 olsrd2 bmx7 ; do
    /etc/init.d/$daemon disable
done
