#!/bin/bash

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

# run installer
OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=$INSTALLER_RELEASE_IMAGE_OVERRIDE /openshift-install create cluster --dir=/root/install
