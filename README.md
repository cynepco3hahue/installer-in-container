# installer-in-container
Number of images that can be used to install OKD 4.0 in the container

## How to use

1. Run `docker run --rm --privileged -it -e INSTALLER_PULL_SECRET=<pull_secret> alukiano/installer:28`
2. Connect to the container via `docker exec -ti <container_id> bash`
3. Exectute setup script `/setup.sh`

***
NOTE: you can get the pull secret [here](https://developers.redhat.com/auth/realms/rhd/protocol/openid-connect/auth?client_id=uhc&redirect_uri=https%3A%2F%2Fcloud.openshift.com%2Fclusters%2Finstall%23pull-secret&state=109aa48e-1779-45d6-9bdc-c156b1e699b4&response_mode=fragment&response_type=code&scope=openid&nonce=b9fe0085-f2c9-4fd7-bd17-e8629f01bbaf).
***

***
NOTE: OpenShift cluster consumes a lot of resources, you should have at least 13Gb of the memory on the machine where do you run the container.
***

After that installer done, you can commit the container via `docker commit <container_id> <new_tag>` and re-use it.

### Where to take oc binary

https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
