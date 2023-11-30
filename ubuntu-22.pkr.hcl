packer {
  required_plugins {
    proxmox = {
      version = " >= 1.0.1"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}


source "proxmox-iso" "ubuntu-server-ci" {
  boot_keygroup_interval = "2s"
  boot_key_interval = "70ms"
  boot_wait    = "12s"
  boot_command = [
                                "c<wait>",
                                "linux /casper/vmlinuz --- autoinstall ds=\"nocloud-net;seedfrom=http://{{.HTTPIP}}:{{.HTTPPort}}/\"",
                                "<enter><wait>",
                                "initrd /casper/initrd",
                                "<enter><wait>",
                                "boot",
                                 "<enter>"
]
 #   type = "proxmox-iso"
    proxmox_url= "${var.proxmox_host}/api2/json"
    insecure_skip_tls_verify =  true
    username = "${var.proxmox_api_user}"
    password = "${var.proxmox_api_password}"

    vm_name = "${var.template_name}"
    vm_id = "${var.vmid}"
    node = "${var.proxmox_node_name}"
    cores = "${var.cores}"
    sockets = "${var.sockets}"
    memory = "${var.memory}"
    os = "l26"
    network_adapters {
        model = "virtio"
        bridge = "vmbr0"
        }                     
    disks {
         type = "scsi"
         disk_size = "${var.disk_size}"
         storage_pool = "${var.datastore}"
         format = "raw"
         cache_mode = "writeback"
         }
                        

   ssh_timeout = "15m"
   ssh_password = "${var.ssh_password}"
   ssh_username = "${var.ssh_username}"

   qemu_agent = true
   unmount_iso = true

   iso_file = "${var.iso}"
   http_directory = "./http"
   template_description = "${var.template_description}"


#end Source
}

# Build Definition to create the VM Template
build {

    name = "ubuntu-server-ci"
    sources = ["proxmox-iso.ubuntu-server-ci"]
    # Provisioning the VM Template for Cloud-Init Integration in Proxmox #1
    provisioner "shell" {
	environment_vars = ["DEBIAN_FRONTEND=noninteractive"]
        pause_before= "20s"
        inline = [
          #  "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
            "date > provision.txt",
            "sudo apt-get update",
            "sudo apt-get -y upgrade",
            "sudo apt-get -y dist-upgrade",
            "sudo apt-get -y install linux-generic linux-headers-generic linux-image-generic",
            "sudo apt-get -y install qemu-guest-agent cloud-init",
            "sudo apt-get -y install procps iputils-ping telnet netcat mc wget curl dnsutils iproute2 vim tcpdump",
            "exit 0"
        ]
    }

    post-processors {
    post-processor "shell-local" {
      inline = [
         "ssh -i key.priv root@${var.proxmox_host_ssh} qm set var.vmid --scsihw virtio-scsi-pci",
         "ssh -i key.priv root@${var.proxmox_host_ssh} qm set var.vmid --ide2 ${var.datastore}:cloudinit",
         "ssh -i key.priv root@${var.proxmox_host_ssh} qm set var.vmid --boot c --bootdisk scsi0",
         "ssh -i key.priv root@${var.proxmox_host_ssh} qm set var.vmid --ciuser     ${var.ssh_username}",
         "ssh -i key.priv root@${var.proxmox_host_ssh} qm set var.vmid --cipassword ${var.ssh_password}",
         "ssh -i key.priv root@${var.proxmox_host_ssh} qm set var.vmid --vga std"
         ]
        }
   }
    

}
