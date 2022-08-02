# ansible-libvirt-fio
## File descriptions

- role/provision/**defaults/main.yml** → default variable values

- role/provision/**tasks/main.yml** → creates virtual machines

- role/provision/**templates/vm.xml.j2** → defines VM properties

**vm-playbook.yaml** → Runs the *provision* role with specified parameters.

- setup.sh → installs required packages and Ansible, generates an SSH key pair and starts the default KVM(?) network
- gen.sh → creates VMs and runs Fio tester on them
- purge.sh → Wipes all libvirt VMs from system

## Configuring variables
**Virtual machine** parameters are located in *vm-playbook.yaml* in the dictionary *vars*.

**Fio** options can be changed at the bottom of the *gen.sh*.

## Usage
1. Run **setup.sh**, which is promptless.

2. Run **gen.sh** and enter how many VMs you want to create. It will ask for confirmation before running a fio benchmark.

3. When you're done, run **purge.sh** remove all VMs.