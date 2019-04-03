#!/usr/bin/bash

# configure iptables
iptables \
    -I INPUT \
    -p tcp \
    -s 192.168.126.0/24 \
    -d 192.168.124.1 \
    --dport 16509 \
    -j ACCEPT \
    -m comment \
    --comment "Allow insecure libvirt clients"

# dnsmasq configuration
original_dnss=$(cat /etc/resolv.conf | egrep "^nameserver" | awk '{print $2}')
echo "nameserver 127.0.0.1" > /etc/resolv.conf

mkdir -p /etc/dnsmasq.d
echo "server=/tt.testing/192.168.126.1" >> /etc/dnsmasq.d/openshift.conf
for dns in $original_dnss; do
    echo "server=/#/$dns" >> /etc/dnsmasq.d/openshift.conf
done

/usr/sbin/dnsmasq \
    --no-resolv \
    --keep-in-foreground \
    --no-hosts \
    --bind-interfaces \
    --pid-file=/var/run/dnsmasq.pid \
    --listen-address=127.0.0.1 \
    --cache-size=400 \
    --clear-on-reload \
    --conf-file=/dev/null \
    --proxy-dnssec \
    --strict-order \
    --conf-file=/etc/dnsmasq.d/openshift.conf &

# start libvirt
/usr/sbin/virtlogd --daemon
/usr/sbin/libvirtd --listen
