FROM fedora:28 AS builder

ENV TAGS libvirt
ENV INSTALLER_DIR /root/go/src/github.com/openshift/installer
ENV INSTALLER_TAG v0.16.1

RUN dnf install -y \
libvirt-devel \
git \
golang-bin \
gcc-c++ && \
dnf clean all

WORKDIR /root/go/src/github.com/openshift/installer

RUN mkdir -p $INSTALLER_DIR; git clone https://github.com/openshift/installer.git $INSTALLER_DIR

COPY hacks /hacks

RUN git checkout $INSTALLER_TAG; \
git apply /hacks/$INSTALLER_TAG; \
./hack/build.sh

FROM alukiano/libvirt:fedora28

ENV TF_VAR_libvirt_master_memory 12288
ENV TF_VAR_libvirt_master_vcpu 4

ENV INSTALLER_RELEASE_IMAGE_OVERRIDE quay.io/openshift-release-dev/ocp-release:4.0.0-0.9

RUN dnf install -y \
openssh-clients \
haproxy && \
dnf clean all

COPY vagrant.key /
RUN chmod 600 /vagrant.key

COPY --from=builder /root/go/src/github.com/openshift/installer/bin/openshift-install /
COPY haproxy.cfg /etc/haproxy
COPY install-config.yaml /
COPY scripts/* /

# Console port
EXPOSE 443/tcp
# API port
EXPOSE 6443/tcp
# SSH master port
EXPOSE 2201/tcp
# SSH worker port
EXPOSE 2202/tcp

ENTRYPOINT [ "/entrypoint.sh" ]
