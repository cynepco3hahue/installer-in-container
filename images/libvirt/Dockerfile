FROM fedora:28

RUN dnf install -y \
    libvirt \
    libvirt-devel \
    libvirt-daemon-kvm \
    libvirt-client \
    qemu-kvm \
    socat \
    selinux-policy \
    selinux-policy-targeted && \
dnf clean all

# configure libvirt
RUN echo 'listen_tls = 0' >> /etc/libvirt/libvirtd.conf; \
echo 'listen_tcp = 1' >> /etc/libvirt/libvirtd.conf; \
echo 'auth_tcp="none"' >> /etc/libvirt/libvirtd.conf; \
echo 'tcp_port = "16509"' >> /etc/libvirt/libvirtd.conf; \
echo 'cgroup_controllers = [ ]' >> /etc/libvirt/qemu.conf

COPY entrypoint.sh /entrypoint.sh
ENTRYPOINT [ "/entrypoint.sh" ]
