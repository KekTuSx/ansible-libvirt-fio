#!/bin/bash

# Ulozi pocet vyskytu stringu "vm*" ve vypisu vsech VMs do promenne = pocet VMs
POCET=`virsh list --all | grep -o "vm*" | wc -l`

# Smaze VMs a jejich image
for i in $(seq 1 $POCET)
do
	virsh shutdown vm$i
	virsh undefine vm$i
	rm /var/lib/libvirt/images/vm$i.qcow2
done
