# installer-in-container
Number of images that can be used to install OKD 4.0 in the container

## How to create cluster

1. Run `docker run --privileged -it -e INSTALLER_PULL_SECRET=<pull_secret> alukiano/installer:0.15.0`
2. Exectute setup script `/setup.sh`

***
NOTE: you can get the pull secret [here](https://developers.redhat.com/auth/realms/rhd/protocol/openid-connect/auth?client_id=uhc&redirect_uri=https%3A%2F%2Fcloud.openshift.com%2Fclusters%2Finstall%23pull-secret&state=109aa48e-1779-45d6-9bdc-c156b1e699b4&response_mode=fragment&response_type=code&scope=openid&nonce=b9fe0085-f2c9-4fd7-bd17-e8629f01bbaf).
***

***
NOTE: OpenShift cluster consumes a lot of resources, you should have at least 14Gb of the memory on the machine where do you run the container.
***

## How to commit cluster for the future usage

1. After the `setup.sh` script is done, you need to stop libvirt `vms` via `virsh shutdown` command
2. Exit from the container `exit`
3. Get the ID of the installer container via `docker ps -a`
4. Commit the new image `docker commit <container_id> <new_tag>`
5. After you can start the container again via `docker run --privileged -it <new_tag>`
6. And in the end you will need to start `vms` via `virsh start` command

## How to connect to the cluster

1. Start the container that you commited
2. Install `kubectl` or `oc` binary
3. Run `export KUBECONFIG=/root/install/auth/kubeconfig`

### Where to take oc binary

https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz

### Where to take kubectl binary

https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-using-native-package-management
