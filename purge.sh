#!/bin/bash
#
# Wipes all libvirt VMs from system

# Counts the occurences of 'vm*' in the command output
COUNT=$(virsh list --all | grep -o "vm*" | wc -l)

# Deletes the VM and its image
for i in $(seq 1 $COUNT)
do
	virsh shutdown vm$i
	virsh undefine vm$i
	rm /var/lib/libvirt/images/vm$i.qcow2
done
