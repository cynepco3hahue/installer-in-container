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

# build installer binary
cd $INSTALLER_DIR
git checkout $INSTALLER_TAG
git apply /hacks/$INSTALLER_TAG
./hack/build.sh

if [[ -z "${INSTALLER_PULL_SECRET}" ]]; then
  echo "You need to pass INSTALLER_PULL_SECRET environment variable to the container"
  exit 1
fi

# inject pull secret into install config
echo "pullSecret: '$INSTALLER_PULL_SECRET'" >> /root/install/install-config.yaml

# run installer
OPENSHIFT_INSTALL_RELEASE_IMAGE_OVERRIDE=$INSTALLER_RELEASE_IMAGE_OVERRIDE bin/openshift-install create cluster --dir=/root/install
