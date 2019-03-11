FROM alukiano/libvirt:28

ENV container docker
ENV TAGS libvirt
ENV TF_VAR_libvirt_master_memory 10240
ENV TF_VAR_libvirt_master_vcpu 4

ENV INSTALLER_DIR /root/go/src/github.com/openshift/installer
ENV INSTALLER_TAG v0.14.0
ENV INSTALLER_RELEASE_IMAGE_OVERRIDE quay.io/openshift-release-dev/ocp-release:4.0.0-0.7

RUN mkdir -p /root/go/src/github.com/openshift/installer; \
    mkdir -p /root/install; \
    git clone https://github.com/openshift/installer.git $INSTALLER_DIR

COPY hacks /hacks
COPY install-config.yaml /root/install
COPY setup.sh /setup.sh

ENTRYPOINT [ "/entrypoint.sh" ]
