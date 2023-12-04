# HPackerTemplate

Create Ubuntu template with cloud-init components.

## Requirements:
1. Ubuntu 22 iso image on Proxmox datastore.
2. Hashicorp packer.

##Variable definitions:
var-def.pkr.hcl

## Variables & values:
vars.auto.pkrvars.hcl

## Before run the packer, update all variables vars.auto.pkrvars.hcl. 
The vaiables that can be different in each environment:
proxmox_host = "http://192.168.1.10:8006"
proxmox_host_ssh = "192.168.1.10"
proxmox_node_name =  "LAB"
proxmox_api_user = "root@pam"
datastore = "local-lvm"
iso = "local:iso/ubuntu-22.04.3-live-server-amd64.iso"

## Hints:
1. Once you change ssh user name - remember to update http/user-data file too (access error).
2. I recommend set 2GB of RAM to speed up image creation and avoid installation errors. You can adjust amount of RAM later once VM is cloned from image.

## Run image creation:
packer build  -var='proxmox_api_password="PasswordforPROXMOX"' -var='ssh_password="sshpasswordforimage"' . 
