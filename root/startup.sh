#! /bin/sh

EXTERNAL_INTERFACE=wg0

ROOT=/etc/wireguard

# Start Wireguard
wg-quick up ${EXTERNAL_INTERFACE}

# Create MINIUPNPD lists.
iptables -t nat    -N MINIUPNPD
iptables -t mangle -N MINIUPNPD
iptables -t filter -N MINIUPNPD
iptables -t nat    -N MINIUPNPD-POSTROUTING
iptables -t nat    -I PREROUTING  -i ${EXTERNAL_INTERFACE} -j MINIUPNPD
iptables -t mangle -I PREROUTING  -i ${EXTERNAL_INTERFACE} -j MINIUPNPD
iptables -t filter -I FORWARD     -i ${EXTERNAL_INTERFACE} ! -o ${EXTERNAL_INTERFACE} -j MINIUPNPD
iptables -t nat    -I POSTROUTING -o ${EXTERNAL_INTERFACE} -j MINIUPNPD-POSTROUTING
iptables -t nat    -F MINIUPNPD
iptables -t mangle -F MINIUPNPD
iptables -t filter -F MINIUPNPD
iptables -t nat    -F MINIUPNPD-POSTROUTING

# Allow traffic in and out if we've started a connection out
iptables -A INPUT -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT -i ${__DEFAULT_INTERFACE}

# Masquarade outgoing traffic on all networks. This hides the internals of the routing from everyone.
iptables -t nat -A POSTROUTING -j MASQUERADE -o ${__DEFAULT_INTERFACE}
iptables -t nat -A POSTROUTING -j MASQUERADE -o ${__INTERNAL_INTERFACE}
iptables -t nat -A POSTROUTING -j MASQUERADE -o ${EXTERNAL_INTERFACE}

# dns
DNS=$(cat ${ROOT}/${EXTERNAL_INTERFACE}.conf | grep DNS | sed "s/^.*DNS.*=\s*\(.*\)\s*$/\\1/")
if [ "${DNS}" != "" ]; then
  echo "nameserver ${DNS}" > /etc/dnsmasq_resolv.conf
else
  cp /etc/resolv.conf /etc/dnsmasq_resolv.conf
fi
/usr/sbin/dnsmasq

# upnp
/usr/sbin/miniupnpd

trap "killall sleep dnsmasq miniupnpd; exit" TERM INT

sleep 2147483647d &
wait "$!"
