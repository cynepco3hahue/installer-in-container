#!/bin/bash

set -xe

haproxy -f /etc/haproxy/haproxy.cfg

until virsh list
do
    sleep 5
done

# Start all VM's
virsh list --name --all | xargs --max-args=1 virsh start

while [[ "$(virsh list --name --all)" != "$(virsh list --name)" ]]; do
    sleep 1
done

# Install latest kubelet
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF
dnf install -y kubectl

# Wait for API server to be up
export KUBECONFIG=/root/install/auth/kubeconfig
kubectl config set-cluster test-1 --server=https://127.0.0.1:6443

until kubectl get nodes
do
    sleep 5
done
