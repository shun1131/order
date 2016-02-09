Vagrant.configure(2) do |config|
  config.vm.box = "centos7"
  config.vm.box_url = "https://f0fff3908f081cb6461b407be80daf97f07ac418.googledrive.com/host/0BwtuV7VyVTSkUG1PM3pCeDJ4dVE/centos7.box"
  config.vm.network "private_network", ip: "192.168.33.34"
  config.vm.provision "shell", path: "provision_vagrant.sh"
  config.vm.provider "virtualbox" do |v|
    v.memory = 2048
  end
  config.vm.synced_folder ".", "/order" #, type: "nfs"
end
