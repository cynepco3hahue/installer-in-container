# installer-in-container
Number of images that can be used to install OKD 4.0 in the container

## How to use

1. Run `docker run --rm --privileged -it -e INSTALLER_PULL_SECRET=<pull_secret> alukiano/installer:28`
2. Connect to the container via `docker exec -ti <container_id> bash`
3. Exectute setup script `/setup.sh`

***
NOTE: you can get the pull secret from the https://developers.redhat.com
***

***
NOTE: OpennShift cluster consumes a lot of resources, you should have at least 13Gb of the memory on the machine where do you run the container.
***

After that installer done, you can commit the container via `docker commit <container_id> <new_tag>` and re-use it.