#!/bin/bash
# This script populates the Ansible inventory file with information of the VM created by Vagrant

# Get Vagrant SSH configuration
VAGRANT_SSH_CONFIG=$(vagrant ssh-config)

# Add the VM's IP address to the known_hosts file to avoid SSH prompts
IP=$(echo "$VAGRANT_SSH_CONFIG" | awk '/HostName/ {print $2}')
ssh-keyscan -H "$IP" >> ~/.ssh/known_hosts 2>/dev/null
echo "IP address $IP added to known_hosts file."

# Populate the Ansible inventory file with the VM's SSH configuration
echo "[demo_vm]" > ../../base_ansible_env/ansible_inventory
echo "$VAGRANT_SSH_CONFIG" | awk '
/Host / {host=$2}
/HostName/ {hostname=$2}
END {print host, "ansible_host="hostname, "ansible_user=ansible", "ansible_ssh_private_key_file=~/.ssh/id_rsa"}
' >> ../../base_ansible_env/ansible_inventory

echo "Inventory file generated successfully!"
cat ../../base_ansible_env/ansible_inventory

echo "You can connect to the VMs using the following command:"
echo "$VAGRANT_SSH_CONFIG" | awk '
/HostName/ {hostname=$2}
END {print "ssh ansible@"hostname}'
