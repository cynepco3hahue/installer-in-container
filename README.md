# installer-in-container
Number of images that can be used to install OKD 4.0 in the container

## How to create cluster

1. Run `docker run --privileged -P -d -e INSTALLER_PULL_SECRET='<pull_secret>' alukiano/installer:0.16.1`
2. Connect to the container via exec command `docker exec -it <container_id> bash`
3. Exectute setup script `/provision.sh`
4. Exit from the container `exit`
5. Commit the container `docker commit <container_id> <new_tag>`
6. Stop and remove the container `docker stop <container_id>; docker rm <container_id>`
7. Now you can re-use the image, run it `docker run --privileged -P -d <new_tag>`
8. Connect to the container `docker exec -it <new_container_id> bash`
9. Exectute setup script `/run.sh`
10. Now you can OKD 4.0 cluster with one master and one machine

***
NOTE: you can get the pull secret [here](https://developers.redhat.com/auth/realms/rhd/protocol/openid-connect/auth?client_id=uhc&redirect_uri=https%3A%2F%2Fcloud.openshift.com%2Fclusters%2Finstall%23pull-secret&state=109aa48e-1779-45d6-9bdc-c156b1e699b4&response_mode=fragment&response_type=code&scope=openid&nonce=b9fe0085-f2c9-4fd7-bd17-e8629f01bbaf).
***

***
NOTE: OpenShift cluster consumes a lot of resources, you should have at least 18Gb of the memory on the machine where do you run the container.
***

## How to SSH to cluster nodes

1. Enter to the container `docker exec -it <container_id> bash`
2. Check VM's IP's via `virsh net-dhcp-leases` command
3. Connect via SSH `ssh -lcore -i /vagrant.key <VM_IP>`

## How to connect to the cluster

1. Start the container that you commited
2. Run `export KUBECONFIG=/root/install/auth/kubeconfig`
3. Run `kubectl` commands

### Where to take oc binary

https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz

### Where to take kubectl binary

https://kubernetes.io/docs/tasks/tools/install-kubectl/#install-kubectl-binary-using-native-package-management
