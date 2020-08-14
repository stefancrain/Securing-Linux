# -*- mode: ruby -*-
# vi: set ft=ruby :

servers=[
  {
    :id => 1,
    :release => "groovy",
    :box => "ubuntu/groovy64" # 20.10
  },
  {
    :id => 2,
    :release => "focal",
    :box => "ubuntu/focal64" # 20.04
  },
  {
    :id => 3,
    :release => "bionic",
    :box => "ubuntu/bionic64" # 18.04
  },
  {
    :id => 4,
    :release => "buster",
    :box => "debian/buster64" # 10
  }
]

Vagrant.configure(2) do |config|
  servers.each do |server|
    config.vm.define server[:release] do |node|
      node.vm.box = server[:box]
      node.vm.boot_timeout = 600
      node.vm.synced_folder ".", "/vagrant", type: "nfs"
      node.vm.hostname = "SLP-"+server[:release]
      node.vm.network "private_network", ip:"172.16.13.#{10+server[:id]}"
      node.vm.provision "shell", inline: "date -s \"$(curl -I google.com 2>&1 | grep Date: | cut -d' ' -f3-6)Z\""
      node.vm.provider "virtualbox" do |vb|
        vb.customize [
          "modifyvm", :id,
          "--memory", 1024,
          "--cpus", 4,
          "--name", "SLP-"+server[:release],
          "--natdnshostresolver1", "on",
          "--ioapic", "on",
          "--audio", "none",
          "--uartmode1", "file", File::NULL,
        ]

        # node.vm.provision :shell, :inline => "cloud-init init --local", :privileged => true
        # node.vm.provision :shell, :inline => "cloud-init init", :privileged => true
        # node.vm.provision :shell, :inline => "cloud-init modules", :privileged => true
      end
    end
  end
end
