#!/bin/bash

echo '-----------------------------------------'
read -r -p 'Kolik VMs chcete vytvorit? ' POCET
read -r -p "Opravdu? (y/n): " confirm && [[ $confirm == [yY] || $confirm == [yY][eE][sS] ]] || exit 1

# Priprava Ansible inventare (seznamu hostu) a host skupiny vms
echo "[vms]" > inventory.ini

# Vytvori VMka, option -e zmeni hodnotu promenne vm, tim padem jmena VMs
for i in $(seq 1 $POCET)
do
	ansible-playbook vm-playbook.yaml -e vm=vm$i
done

# Delay, aby vsechny VM dostali IP
sleep 20s

# Zapise IP adresy vsech VM do vlastniho Ansible inventare
for i in $(seq 1 $POCET)
do
	virsh domifaddr vm$i | grep -o -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' >> inventory.ini
done

# Vypnuti SSH strict host checking = SSH se nebude ptat, jestli verime vzdalenemu stroji
echo "[vms:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no'" >> inventory.ini

echo "Seznam VMs:"
virsh list --all

echo "Seznam adres VMs:"
cat /root/vm-gen/inventory.ini
#ansible-inventory -i inventory.ini --list

printf "\n"
echo "********* Instalace Fio na VMs *********"

# Option -qq a presmerovani do /dev/null omezi vystup jen na chyby; option -f by mel zaridit, ze to pobezi na vsech VMs najednou 
ansible vms -i inventory.ini -m shell -a 'apt-get -qq update  > /dev/null
apt-get -qq install -y fio > /dev/null' -f $POCET

echo "********* Instalace Fio dokoncena *********"
printf "\n"

while true
do
	read -r -p "Spustit test? (y/n) " yn

	case $yn in 
		[yY] ) echo Spusteno;
			break;;
		[nN] ) echo Konec...;
			exit;;
		* ) echo y/n;;
	esac
done

# Fio tester - spusteni; NASTAVENI
## https://fio.readthedocs.io/en/latest/fio_doc.html
ansible vms -i inventory.ini -m shell -a 'sudo fio --name=global \
--ioengine=libaio --rw=randrw --bs=32k --size=128M \
--runtime=15 --time_based --group_reporting \
--numjobs=3 --name=test --eta-newline=1' -f $POCET
