#!/bin/bash
#
# Installs required packages and Ansible, generates an SSH key pair and starts the default KVM(?) network

# Installs packages for KVM and editing .qcow2 images
apt update
apt install -y qemu-kvm qemu-system \
libvirt-daemon-system libvirt-clients bridge-utils \
libguestfs-tools python3-libvirt

# Installs Ansible and its community module for libvirt
echo "deb http://ppa.launchpad.net/ansible/ansible/ubuntu focal main" >> /etc/apt/sources.list
apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 93C4A3FD7BB9C367
apt update
apt install -y ansible
ansible-galaxy collection install community.libvirt

# Creates an SSH key
ssh-keygen -q -t rsa -b 4096 -N '' -f /root/.ssh/id_rsa 

virsh net-start default
