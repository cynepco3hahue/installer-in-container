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

## generate ssh key
mkdir -p /root/.ssh/
ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""

cd $INSTALLER_DIR
git checkout $INSTALLER_TAG
git apply /hacks/$INSTALLER_TAG
./hack/build.sh

if [[ -z "${INSTALLER_PULL_SECRET}" ]]; then
  echo "You need to pass INSTALLER_PULL_SECRET environment variable to the container"
  exit 1
fi

mkdir -p /root/install
cp /install-config.yaml /root/install/

# inject pull secret into install config
echo "pullSecret: '$INSTALLER_PULL_SECRET'" >> /root/install/install-config.yaml

# inject ssh public key into install config
ssh_pub_key=$(cat /root/.ssh/id_rsa.pub)
echo "sshKey: '$ssh_pub_key'" >> /root/install/install-config.yaml

# run installer
OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=$INSTALLER_RELEASE_IMAGE_OVERRIDE bin/openshift-install create cluster --dir=/root/install
