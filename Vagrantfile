Vagrant.configure(2) do |config|

    config.vm.box = "kimoi/debian"
    config.vm.box_url = "https://vagrant.madokami.com/metadata.json"

    config.vm.network "private_network", ip: "192.168.33.19"

    config.vm.synced_folder ".", "/vagrant", :mount_options => [ 'dmode=775', 'fmode=775' ]

    config.vm.provision "shell" do |s|
        s.path = "vagrant-provision.sh"
        s.args = [
            "noko-vm", # Hostname
            "noko" # DB name
        ]
    end

    config.vm.provider "virtualbox" do |vb|
        # Display the VirtualBox GUI when booting the machine
        # vb.gui = true
    end
end