#!/bin/bash
set -x

VERSION=1.20

# load required kernel modules
for mod in overlay br_netfilter; do
    lsmod | grep "$mod" >/dev/null 2>&1
    if [ "$?" -ne 0 ]; then
# module not loaded
        echo "loading kernel module '$mod'"
        sudo modprobe "$mod"
        echo "$mod" | sudo tee -a /etc/modules-load.d/cri-o.conf
    fi
done

# set kernel parameters
SYSCTL_CONF=/etc/sysctl.d/99-kubernetes-cri.conf
if [ ! -e "$SYSCTL_CONF" ]; then
    cat <<EOS | sudo tee "$SYSCTL_CONF"
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOS
    sudo sysctl -p"$SYSCTL_CONF"
fi

# detect OS
DIST_ID=$(lsb_release -i -s)
case "$DIST_ID" in
    Ubuntu)
        OS="xUbuntu_$(lsb_release -r -s)"
        ;;
    *)
        echo "Error: Cannot detect OS distribution / not supported, DIST_ID=$DIST_ID"
        exit 1
        ;;
esac

# import signature key
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | sudo -E apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo -E apt-key add -

# add apt repository
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list

# install CRI-O
sudo -E apt-get update -y
sudo -E apt-get install -y cri-o cri-o-runc

# start CRI-O
sudo systemctl daemon-reload
sudo systemctl enable crio
sudo systemctl start crio

# install crictl
VERSION="v1.21.0"
cd /tmp
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

echo "Done!"
