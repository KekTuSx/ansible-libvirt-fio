#!/bin/bash
#
# Creates VMs and runs Fio tester on them

echo '-----------------------------------------'
read -r -p 'How many virtual machines do you wish to create? ' COUNT
read -r -p "Are you sure? (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Preps an Ansible inventory file for VMs
echo "[vms]" > inventory.ini

# Creates VMs via vm-playbook.yaml
for i in $(seq 1 $COUNT)
do
	ansible-playbook vm-playbook.yaml -e vm=vm$i
done

# Delay so that every VM gets an IP address
sleep 20s

# Writes IP addresses of all VMs to an inventory file
for i in $(seq 1 $COUNT)
do
	virsh domifaddr vm$i | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' >> inventory.ini
done

# Disables SSH StrictHostKeyChecking in order to not get prompted when provisioning VMs
echo "[vms:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory.ini

echo "List of VMs:"
virsh list --all

echo "List of VMs IPs:"
cat /root/vm-gen/inventory.ini
#ansible-inventory -i inventory.ini --list

echo -e "\n********* Starting installation of Fio on VMs *********"

# Option -qq a redirect into /dev/null filters the output to only errors
# Option -f will run command on all VMs 
ansible vms -i inventory.ini -m shell -a 'apt-get -qq update  > /dev/null
apt-get -qq install -y fio > /dev/null' -f $COUNT

echo -e "********* Installation of Fio on VMs completed *********\n"

while true
do
	read -r -p "Run test? (y/n) " yn

	case $yn in 
		[yY] ) echo Commencing...;
			break;;
		[nN] ) echo Aborting...;
			exit;;
		* ) echo y/n;;
	esac
done

# Runs Fio on all VMs
## CHANGE SETTINGS HERE
ansible vms -i inventory.ini -m shell -a 'sudo fio --name=global \
--ioengine=libaio --rw=randrw --bs=32k --size=128M \
--runtime=15 --time_based --group_reporting \
--numjobs=3 --name=test --eta-newline=1' -f $COUNT
