FROM openwrt/rootfs:x86_64-openwrt-22.03

RUN mkdir -p /var/lock
# Install OpenVPN instructions by NordVPN https://support.nordvpn.com/Connectivity/Router/1047411192/OpenWRT-CI-setup-with-NordVPN.htm
RUN opkg update && \
    opkg install openvpn-openssl \
      ip-full \
      luci-app-openvpn
RUN opkg list-upgradable | awk '{print $1}' | xargs opkg upgrade || true
RUN /etc/init.d/openvpn enable

# Copy NordVPN Conf files
COPY ./conf/* /etc/openvpn/

# Create a new network interface.
RUN uci set network.nordvpntun=interface && \
    uci set network.nordvpntun.proto='none' && \
    uci set network.nordvpntun.ifname='tun0' && \
    uci commit network

# Create a new firewall zone and add a forwarding rule from LAN to VPN:
RUN uci add firewall zone && \
    uci set firewall.@zone[-1].name='vpnfirewall' && \
    uci set firewall.@zone[-1].input='REJECT' && \
    uci set firewall.@zone[-1].output='ACCEPT' && \
    uci set firewall.@zone[-1].forward='REJECT' && \
    uci set firewall.@zone[-1].masq='1' && \
    uci set firewall.@zone[-1].mtu_fix='1' && \
    uci add_list firewall.@zone[-1].network='nordvpntun' && \
    uci add firewall forwarding && \
    uci set firewall.@forwarding[-1].src='lan' && \
    uci set firewall.@forwarding[-1].dest='vpnfirewall' && \
    uci commit firewall

# Now you need to configure the DNS servers. The simplest approach is to use NordVPN DNS for the WAN interface of the router. Here’s how to add NordVPN DNS:
#    Note that the original instructions require to run the following command
#        uci del network.wan.dns
#    This command was ommitted as it throws an error that that dns field is not part of the interface, and thus cannot be removed.
RUN uci set network.wan.peerdns='0' && \
    uci add_list network.wan.dns='103.86.96.100' && \
    uci add_list network.wan.dns='103.86.99.100' && \
    uci commit

# To prevent traffic leakage in case the VPN tunnel drops
COPY firewall.user.prevent.leak.conf /tmp
RUN cat /tmp/firewall.user.prevent.leak.conf >> /etc/firewall.user && \
    rm  /tmp/firewall.user.prevent.leak.conf
COPY 99-prevent-leak /etc/hotplug.d/iface/

# Script to reconnect
COPY reconnect.sh /etc/openvpn/

