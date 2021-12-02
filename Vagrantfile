# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "wp" do |wp|
    wp.vm.box = "ubuntu/bionic64" 
    wp.vm.hostname = "wp"
    wp.vm.network "private_network", ip: "192.168.100.10", nic_type: "virtio", virtualbox__intnet: "keepcoding"
    wp.vm.network "forwarded_port", guest: 80, host: 8081
    wp.vm.synced_folder ".", "/vagrant"    
    wp.vm.provision "shell", path: "install_wp.sh"        
    wp.vm.provider "virtualbox" do |vb|
        vb.memory= 512
        vb.cpus = 2
        vb.default_nic_type = "virtio"
    end
  end

  config.vm.define "elk" do |elk|
      elk.vm.box = "ubuntu/bionic64" 
      elk.vm.hostname = "elk"
      elk.vm.network "private_network", ip: "192.168.100.11", nic_type: "virtio", virtualbox__intnet: "keepcoding" 
      elk.vm.network "forwarded_port", guest: 5601, host: 5601
      elk.vm.network "forwarded_port", guest: 9200, host: 9200
      elk.vm.synced_folder ".", "/vagrant"
      elk.vm.provision "shell", path: "install_elk.sh" 
      elk.vm.provider "virtualbox" do |vb|
          vb.memory= 4096
          vb.cpus = 2
          vb.default_nic_type = "virtio"
      end
  end
  
end