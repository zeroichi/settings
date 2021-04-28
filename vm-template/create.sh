#!/bin/bash
# vim:set ts=2 sw=2:
set -e

# VM name (use directory name where this script is placed)
VMNAME=$(basename $(cd $(dirname $0); pwd))
# # of vCPUs assigned to the VM
VCPUS=4
# RAM size assigned to the VM
RAMSIZE=16  # Unit: GB
# Disk size assigned to the VM
DISKSIZE=200  # Unit: GB
# Network interface(s)
NET1="--network network:default"
#NET2="--network bridge:br0"
#NET2_IP="192.168.111.111"
#NET2_GW="192.168.111.1"
# Directory where image files will be stored
#IMAGE_DIR=/var/lib/libvirt/images
IMAGE_DIR=$(dirname $0)
# VM image file name
IMAGE_FILE=${VMNAME}.qcow2
BASE_DIR=/var/lib/libvirt/images

# Base image file name (must exists before running the script)

# CentOS 7
# URL: https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud-2003.qcow2.xz
#BASE_FILE=CentOS-7-x86_64-GenericCloud-2003.qcow2

# CentOS 8
# URL: https://cloud.centos.org/centos/8/x86_64/images/CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2
#BASE_FILE=CentOS-8-GenericCloud-8.3.2011-20201204.2.x86_64.qcow2

# Debian 10 (buster)
# URL: https://cloud.debian.org/images/cloud/buster/20210208-542/debian-10-generic-amd64-20210208-542.qcow2
#BASE_FILE=debian-10-generic-amd64-20210208-542.qcow2

# Ubuntu 18.04 (bionic)
# URL: https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img
#BASE_FILE=bionic-server-cloudimg-amd64.img
#BASE_FILE=ubuntu-18.04-server-cloudimg-amd64.img

# Ubuntu 20.04 (focal)
# URL: https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64.img
# URL: https://cloud-images.ubuntu.com/focal/current/focal-server-cloudimg-amd64-disk-kvm.img
BASE_FILE=focal-server-cloudimg-amd64.img
#BASE_FILE=focal-server-cloudimg-amd64-disk-kvm.img
#BASE_FILE=ubuntu-20.04-server-cloudimg-amd64-disk-kvm.img

# OpenSUSE Leap 15.2
# URL: https://download.opensuse.org/repositories/Cloud:/Images:/Leap_15.2/images/openSUSE-Leap-15.2.x86_64-NoCloud.qcow2
#BASE_FILE=openSUSE-Leap-15.2.x86_64-NoCloud.qcow2

# Guest VM OS variant
OS_VARIANT=ubuntu18.04

USE_CLOUDINIT=y
USER_PASS=ubuntu

CIDATA_PATH=$(dirname $0)/cidata-${VMNAME}.iso
IMAGE_PATH=$IMAGE_DIR/$IMAGE_FILE
BASE_PATH=$BASE_DIR/$BASE_FILE

echo "VMNAME ........ $VMNAME"
echo "VCPUS ......... $VCPUS"
echo "RAMSIZE ....... $RAMSIZE G"
echo "DISKSIZE ...... $DISKSIZE G"
echo "NETWORK 1 ..... $NET1"
if [ -n "$NET2" ]; then
  echo "NETWORK 2 ..... $NET2"
fi
echo "USE_CLOUDINIT . $USE_CLOUDINIT"
if [ "$USE_CLOUDINIT" = y ]; then
  echo "CIDATA_PATH ... $CIDATA_PATH"
fi
echo "IMAGE_PATH .... $IMAGE_PATH"
echo "BASE_PATH ..... $BASE_PATH"
echo
read -p "Is this OK? ('y' to proceed) " ANS
if [ "$ANS" != "y" -a "$ANS" != "Y" ]; then
  echo "Aborted"
  exit 1
fi

# Check if the base image exists
if [ ! -r "$BASE_PATH" ] && sudo [ ! -r "$BASE_PATH" ]; then
  echo "error: base image file $BASE_PATH not found."
  exit 1
fi

# Check if the VM image already exists
# if not, create the new one
if [ ! -f "$IMAGE_PATH" ]; then
  echo "info: image file $IMAGE_PATH not found. creating new image"
  qemu-img create -b "$BASE_PATH" -f qcow2 -F qcow2 "$IMAGE_PATH" ${DISKSIZE}G
  if [ $? -ne 0 ]; then
    echo "error: failed to create image"
    exit 1
  fi
fi

# Dump the image info
qemu-img info "$IMAGE_PATH"

# Check if the cloud-init data file exists
# if not, generate it
if [ "$USE_CLOUDINIT" = y -a ! -r "$CIDATA_PATH" ]; then
  mkdir -p $(dirname $CIDATA_PATH)
  pushd $(dirname $CIDATA_PATH)

  cat > user-data <<-EOS
#cloud-config
#password: $USER_PASS
#chpasswd: {expire: False}
ssh_pwauth: False
EOS

  # If $NET2 is set, write netplan configuration to /etc/netplan/90-ens3.yaml
  [ -n "$NET2" ] && cat >> user-data <<-EOS
write_files:
- path: /etc/netplan/90-ens3.yaml
  content: |
    network:
        ethernets:
            ens3:
                dhcp4: false
                addresses:
                - ${NET2_IP}/24
                #gateway4: ${NET2_GW}
                nameservers:
                    addresses:
                    - 1.1.1.1
        version: 2
EOS

  # add commands to run on startup
  # note: need to create /etc/cloud/cloud-init.disabled to prevent cloud-init start on second time
  cat >> user-data <<-EOS
users:
- name: vmuser
  lock_passwd: false
  passwd: \$6\$bfQzhTFhP7r\$wiFCzPnc08PtQs9U1XbxMpba49FYbkNMzyWPtR5QDBschLAC8jJE6dI.CXA7TJWAa67S5JNE25p247mEEQqKc.
  ssh_authorized_keys:
EOS
  # add host's ssh pubkey
  if [ -r ~/.ssh/id_ed25519.pub ]; then
    echo "  - $(cat ~/.ssh/id_ed25519.pub)" >> user-data
  elif [ -r ~/.ssh/id_rsa.pub ]; then
    echo "  - $(cat ~/.ssh/id_rsa.pub)" >> user-data
  fi
  cat >> user-data <<-EOS
  sudo: ALL=(ALL) NOPASSWD:ALL
packages:
- git
runcmd:
- sudo chsh -s /bin/bash vmuser
- sudo -u vmuser git clone "https://github.com/zeroichi/settings" /home/vmuser/.settings
#- sudo -u vmuser /home/vmuser/.settings/setup
- touch /etc/cloud/cloud-init.disabled
- sudo -u vmuser mkdir -p /home/vmuser/.ssh/
- sudo -u vmuser ssh-keygen -t ed25519 -N '' -f /home/vmuser/.ssh/id_ed25519
# to install docker, uncomment the following 3 lines
#- curl -fsSL "https://releases.rancher.com/install-docker/19.03.sh" -o /tmp/install-docker.sh
#- sh /tmp/install-docker.sh
#- usermod -aG docker vmuser
- sleep 1
- echo "                                         "
- echo "@@@@@@@@@@@@ SETUP COMPLETED @@@@@@@@@@@@"
- echo "                                         "
- echo "  Press Ctrl+] to detach from console    "
- echo "                                         "
- echo "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@"
- echo "                                         "
EOS

  cat > meta-data <<-EOS
instance-id: $VMNAME
local-hostname: $VMNAME
EOS

  genisoimage -output "$CIDATA_PATH" -volid cidata -joliet -rock user-data meta-data
  popd
fi

if [ "$USE_CLOUDINIT" = y ]; then
  # pass --cdrom argument to virt-install and attach cloud-init meta data on the VM
  CDROM="--disk $CIDATA_PATH,device=cdrom"
else
  # use virt-customize to set user password
  SSH_KEY=$(ls $HOME/.ssh/id*.pub | head -n 1)
  if [ -n "$SSH_KEY" ]; then
    #SSH_INJECT="--ssh-inject ubuntu:file:$SSH_KEY"
    true
  fi
  sudo virt-customize -a "$IMAGE_PATH" --password "ubuntu:password:$USER_PASS" $SSH_INJECT
fi

echo 1 > "${VMNAME}.vmname"

virt-install \
  --name $VMNAME \
  --ram $(($RAMSIZE * 1024)) \
  --vcpus $VCPUS \
  --cpu host \
  --arch x86_64 \
  --os-type linux \
  --os-variant $OS_VARIANT \
  --hvm \
  --virt-type kvm \
  --disk $IMAGE_PATH \
  $CDROM \
  --boot hd \
  $NET1 \
  $NET2 \
  --graphics none \
  --serial pty \
  --console pty \

# Print MAC & IP addresses of the created VM
MACADDR=$(virsh domiflist $VMNAME | grep default | awk '{print $5}' | head -n1)
if [ -n "$MACADDR" ]; then
  echo "Target VM MAC address = $MACADDR"
  DHCP_INFO=$(virsh net-dhcp-leases default | grep -i $MACADDR)
  IP_ADDR=$(echo "$DHCP_INFO" | awk '{print $5}' | cut -d/ -f1)
  echo "Use ssh command to login: (password=vmuser)"
  echo "  ssh vmuser@${IP_ADDR}"
fi
