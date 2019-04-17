
FROM fedora:28 AS builder

ENV TAGS libvirt
ENV INSTALLER_DIR /root/go/src/github.com/openshift/installer
ENV INSTALLER_TAG v0.16.1

RUN yum install -y \
    libvirt-devel \
    git \
    golang-bin \
    gcc-c++

WORKDIR /root/go/src/github.com/openshift/installer

RUN mkdir -p $INSTALLER_DIR; git clone https://github.com/openshift/installer.git $INSTALLER_DIR

COPY hacks /hacks

RUN git checkout $INSTALLER_TAG; \
git apply /hacks/$INSTALLER_TAG; \
./hack/build.sh

FROM alukiano/libvirt:fedora28

ENV TF_VAR_libvirt_master_memory 10240
ENV TF_VAR_libvirt_master_vcpu 4

ENV INSTALLER_RELEASE_IMAGE_OVERRIDE quay.io/openshift-release-dev/ocp-release:4.0.0-0.11

COPY --from=builder /root/go/src/github.com/openshift/installer/bin/openshift-install /

COPY install-config.yaml /
COPY setup.sh /

EXPOSE 6443/tcp
EXPOSE 8443/tcp

ENTRYPOINT [ "/entrypoint.sh" ]
