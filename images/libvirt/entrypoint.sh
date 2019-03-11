#!/usr/bin/bash

# libvirt configuration
echo "cgroup_controllers = [ ]" >> /etc/libvirt/qemu.conf

# iptables configuration
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
original_dns=$(cat /etc/resolv.conf | grep nameserver | head -n 1 | awk '{print $2}')
echo "nameserver 127.0.0.1" > /etc/resolv.conf

mkdir -p /etc/dnsmasq.d
echo "server=/tt.testing/192.168.126.1" >> /etc/dnsmasq.d/openshift.conf
echo "server=/#/$original_dns" >> /etc/dnsmasq.d/openshift.conf
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
    --conf-dir=/etc/dnsmasq.d &

# start libvirt
/usr/sbin/virtlogd &
/usr/sbin/libvirtd --listen
