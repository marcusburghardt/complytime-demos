# ComplyTime Demos

This repository is intended to be used as base for [ComplyTime](https://github.com/complytime/complytime) and [trestlebot](https://github.com/complytime/trestle-bot) Demos.

As ComplyTime and trestlebot are evolving on their features, as well as [CaC/content](https://github.com/complianceAsCode/content) are being transformed to OSCAL and vice-versa, we can show more complex demos with real content.

This repository targets some goals:
* Standardize the demos so they can be easily extended
* Provide a consistent experience along the demos
* Allow the team and stakeholders to reproduce the demos on their computers

## Architecture

The idea is pretty simple: Use simple and easily available tools so a wider audience can quickly on-board.

These tools are:
* Vagrant: Used to spin up a VM with custom repositories, some essential packages and an Ansible user
* Ansible: Used to configure the VM in an easily reproducible way for each demo

## Directory Structure

```
complytime-demos/
├── base_ansible_env/               # Centralize Ansible configuration, inventory, Playbooks and the resources used by Playbooks
│ ├── files/                        # Sample files used by Playbooks
│ ├── templates/                    # Jinja2 templates used by Playbooks
│ ├── ansible_inventory             # This file is automatically updated by "populate_ansible_inventory.sh"
│ └── ansible.cfg                   # Ansible configuration file specific for "base_ansible_env" directory
├── base_rhel9_env/                 # Centralize instructions to create a rhel9 demo VM
│ ├── populate_ansible_inventory.sh # Script to collect information for Vagrant VM and populate the Ansible inventory
│ └── Vagrantfile                   # Vagrant instructions to create a local VM
├── scripts/                        # Supporting scripts (WIP)
└── README.md                       # Main file to centralize instructions and other relevant information for demos.s
```

## Get Your Hands Dirty

### Base RHEL 9 VM
```bash
git clone https://github.com/marcusburghardt/complytime-demos.git
cd complytime-demos/base_rhel9_vm
vagrant up
./populate_ansible_inventory.sh
```

It is recommended to create a snapshot of the fresh VM if you plan to work on a new Demo or experiment different Demos.
This way you can save time provisioning a new Vagrant Box.

### Base Ansible Environment

Create and execute the Playbooks from Base Ansible Environment

```bash
cd ../base_ansible_env
ansible-playbook populate_complytime_vm.yml
```

After running this Playbook a directory structure similar to this is expected in /home/ansible:
```
...
├── bin
│   └── complytime
├── .config
│   └── complytime
│       ├── bundles
│       │   └── sample-component-definition.json
│       ├── controls
│       │   └── sample-profile.json
│       └── plugins
│           ├── c2p-openscap-manifest.json
│           ├── openscap-plugin
│           └── openscap-plugin.yml
...
```
