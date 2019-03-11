FROM fedora:28

ENV container docker

RUN dnf install -y \
    git \
    golang-bin \
    gcc-c++ \
    libvirt \
    libvirt-devel \
    libvirt-daemon-kvm \
    libvirt-client \
    qemu-kvm \
    socat \
    genisoimage \
    selinux-policy selinux-policy-targeted \
    augeas; \
    dnf clean all

COPY augconf /augconf
RUN augtool -f /augconf

RUN setcap CAP_NET_BIND_SERVICE=+eip /usr/bin/qemu-system-x86_64

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
