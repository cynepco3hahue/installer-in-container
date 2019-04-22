#!/bin/bash

set -xe

until virsh list
do
    sleep 5
done

# create libvirt storage pool
virsh pool-define /dev/stdin <<EOF
<pool type='dir'>
  <name>default</name>
  <target>
    <path>/var/lib/libvirt/images</path>
  </target>
</pool>
EOF
virsh pool-start default
virsh pool-autostart default

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

# wait until dnsmasq will start
sleep 5

if [[ -z "${INSTALLER_PULL_SECRET}" ]]; then
  echo "You need to pass INSTALLER_PULL_SECRET environment variable to the container"
  exit 1
fi

mkdir -p /root/install
cp /install-config.yaml /root/install/

# inject pull secret into install config
echo "pullSecret: '$INSTALLER_PULL_SECRET'" >> /root/install/install-config.yaml

# inject vagrant ssh public key into install config
ssh_pub_key="ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key"
echo "sshKey: '$ssh_pub_key'" >> /root/install/install-config.yaml

# increase workers memory to 6144MB
OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=$INSTALLER_RELEASE_IMAGE_OVERRIDE /openshift-install create manifests --dir=/root/install
sed -i -e 's/domainMemory: 4096/domainMemory: 6144/' /root/install/openshift/99_openshift-cluster-api_worker-machineset-0.yaml

# run installer
OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=$INSTALLER_RELEASE_IMAGE_OVERRIDE /openshift-install create cluster --dir=/root/install

# Make sure that all VMs can reach the internet
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i tt0 -o eth0 -j ACCEPT

# Shutdown VM's
virsh list --name | xargs --max-args=1 virsh shutdown

while [[ "$(virsh list --name)" != "" ]]; do
    sleep 1
done

# remove the cache
rm -rf /root/.cache/*
