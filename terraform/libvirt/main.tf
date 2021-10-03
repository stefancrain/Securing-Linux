# see https://github.com/hashicorp/terraform
terraform {
  required_version = ">= 0.13"
  required_providers {
    # see https://registry.terraform.io/providers/hashicorp/random
    random = {
      source = "hashicorp/random"
      version = "3.1.0"
    }
    # see https://registry.terraform.io/providers/hashicorp/template
    template = {
      source = "hashicorp/template"
      version = "2.2.0"
    }
    # see https://github.com/dmacvicar/terraform-provider-libvirt
    libvirt = {
      source = "dmacvicar/libvirt"
      version = "0.6.3"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

variable "prefix" {
  default = "terraform_example"
}

# see https://github.com/dmacvicar/terraform-provider-libvirt/blob/v0.6.3/website/docs/r/network.markdown
resource "libvirt_network" "example" {
  name = var.prefix
  mode = "nat"
  domain = "example.test"
  addresses = ["10.17.3.0/24"]
  dhcp {
    enabled = false
  }
  dns {
    enabled = true
    local_only = false
  }
}

# cloudinit
data "template_file" "ubuntu_user_data" {
  template = file("${path.module}/ubuntu/cloud_init.yml")
}

data "template_file" "ubuntu_network_config" {
  template = file("${path.module}/ubuntu/network_config.yml")
}
resource "libvirt_cloudinit_disk" "ubuntu_commoninit" {
  name           = "commoninit.iso"
  user_data      = data.template_file.ubuntu_user_data.rendered
  network_config = data.template_file.ubuntu_network_config.rendered
}

# disks
# We fetch the latest ubuntu release image from their mirrors
resource "libvirt_volume" "os_image_ubuntu" {
  name   = "os_image_ubuntu"
  source = "iso/ubuntu/20.04/ubuntu-server-cloudimg-amd64.img"
  format = "qcow2"
}
resource "libvirt_volume" "example_root" {
  name           = "os_image_ubuntu_root.qcow2"
  base_volume_id = libvirt_volume.os_image_ubuntu.id
  format         = "qcow2"
  size           = 4*1024*1024*1024
}
resource "libvirt_volume" "example_data" {
  name           = "os_image_ubuntu_data.qcow2"
  format         = "qcow2"
  size           = 4*1024*1024*1024
}

# see https://github.com/dmacvicar/terraform-provider-libvirt/blob/v0.6.3/website/docs/r/domain.html.markdown
resource "libvirt_domain" "example" {
  name = var.prefix
  # cpu = {
  #   mode = "host-passthrough"
  # }
  vcpu = 6
  memory = 1024*6
  qemu_agent = true
  cloudinit = libvirt_cloudinit_disk.ubuntu_commoninit.id

  disk {
    volume_id = libvirt_volume.example_root.id
    scsi = true
  }
  disk {
    volume_id = libvirt_volume.example_data.id
    scsi = true
  }
  network_interface {
    network_id = libvirt_network.example.id
    # wait_for_lease = true
    addresses = ["10.17.3.2"]
  }
  provisioner "remote-exec" {
    inline = [
      <<-EOF
      set -x
      id
      uname -a
      cat /etc/os-release
      echo "machine-id is $(cat /etc/machine-id)"
      hostname --fqdn
      cat /etc/hosts
      sudo sfdisk -l
      lsblk -x KNAME -o KNAME,SIZE,TRAN,SUBSYSTEMS,FSTYPE,UUID,LABEL,MODEL,SERIAL
      mount | grep ^/dev
      df -h
      EOF
    ]
    connection {
      type = "ssh"
      user = "ubuntu"
      host = self.network_interface[0].addresses[0]
      private_key = file("${path.module}/ubuntu/ssh_id_shared")
    }
  }
  timeouts {
    create = "2m"
  }
}

output "ip" {
  value = length(libvirt_domain.example.network_interface[0].addresses) > 0 ? libvirt_domain.example.network_interface[0].addresses[0] : ""
}
