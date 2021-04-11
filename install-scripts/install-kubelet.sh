#!/bin/bash
set -x

VER_FILTER='1\.20'

# create kubelet default config file (for CRI-O)
cat <<EOF | sudo tee /etc/default/kubelet
KUBELET_EXTRA_ARGS=--cgroup-driver=systemd --container-runtime=remote --container-runtime-endpoint="unix:///var/run/crio/crio.sock"
EOF

# import signature key
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# add kubernetes repository for apt
cat <<EOF | sudo tee /etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
sudo -E apt-get update -y

# get version to be installed which meets VER_FILTER constraint
VERSION=$(apt-cache policy kubelet | grep "$VER_FILTER" | awk '{print $1}' | head -n1)

# install kubelet, kubeadm and kubectl
sudo apt-get install -y kubelet=$VERSION kubeadm=$VERSION kubectl=$VERSION

echo "Done!"
