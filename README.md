# <span style="color:red">V</span><span style="color:orange">M</span><span style="color:yellow">-</span><span style="color:lime">G</span><span style="color:blue">E</span><span style="color:violet">N</span>

Vytvořeno pomocí Bashe a [Ansible](https://docs.ansible.com/) + [fio (flexible I/O tester)](https://fio.readthedocs.io/en/latest/fio_doc.html).
## Popis souborů

**role/provision** → Ansible role = sbírka konfiguračních souborů

- role/provision/**defaults/main.yml** → výchozí hodnoty proměnných

- role/provision/**tasks/main.yml** → funkce, které vytvoří VM

- role/provision/**templates/vm.xml.j2** → definice vlastností VM ve formátu Jinja XML

**vm-playbook.yaml** → Ansible playbook, který spustí roli *provision* se specifikovanými parametry

## Nastavení proměnných
Parametry **virtuálních strojů** je možno změnit v souboru *vm-playbook.yaml* ve slovníku *vars*.

Parametry **fia** se dají změnit na posledních 6 řádcích skriptu *gen.sh*.

## Postup
1. Spustit **setup.sh**, který nainstaluje Ansible a potřebné package, vytvoří SSH klíče a startne výchozí virtuální síť.

2. Spustit **gen.sh**; zeptá se, kolik virtuálních strojů chceme vytvořit, vytvoří je, zapíše jejich IP adresy do inventáře pro Ansible *inventory.ini* a nainstaluje na nich fio. Poté se zeptá, jestli chceme pokračovat a spustit na VMs fio.

3. **Purge.sh** shutdownne a undefinene všechny virtuální stroje a smaže jejich image v */var/lib/libvirt/images*.