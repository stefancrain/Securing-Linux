# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Read YAML file with box details
require 'yaml'
hosts = YAML.load_file(File.join(File.dirname(__FILE__), 'hosts.yml'))

# Set cpus to number of host cpus
cpus = case RbConfig::CONFIG['host_os']
  when /darwin/ then `sysctl -n hw.ncpu`.to_i
  when /linux/ then `nproc`.to_i
  else 2
end

Vagrant.configure(2) do |config|
  hosts.each do |host|

    # Create vars from box name
    group = host["group"]
    codename = host["codename"]
    hostname = group+"-"+codename
    if Vagrant.has_plugin?("vagrant-vbguest")
      config.vbguest.auto_update = true
      config.vbguest.no_remote = true
      config.vbguest.iso_path = "./VBoxGuestAdditions_6.1.12.iso"
    end

    # https://download.virtualbox.org/virtualbox/6.1.12/VBoxGuestAdditions_6.1.12.iso

    # Configure host
    config.vm.define hostname do |node|
      node.vm.box = host["box"]
      node.vm.synced_folder '.', '/vagrant', disabled: true
      node.vm.network "private_network", ip: host["ip"]
      node.vm.hostname = hostname
      node.vm.provider "virtualbox" do |vb|
        vb.customize [
          "modifyvm", :id,
          "--memory", 1024,
          "--cpus", cpus,
          "--name", hostname,
          "--ioapic", "on",
          "--audio", "none",
          "--uartmode1", "file", File::NULL,
          "--groups", "/Securing-Linux/"+group,
        ]
      end
      # enable ssh via vagrant and ansible
      node.ssh.config = ".vagrant_ssh_key"
      node.ssh.insert_key = false
      node.ssh.private_key_path = ['~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa']
      node.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"
    end
  end
end
