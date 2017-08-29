Vagrant.configure("2") do |config|

  config.vm.box = "petergdoyle/CentOS-7-x86_64-Minimal-1511"
  config.ssh.insert_key = false

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]
    vb.memory = "512"
    vb.cpus = 1
  end

  config.vm.hostname = "engine4.cleverfishsoftware.com"
  #config.vm.network "public_network", ip: "192.168.1.84", bridge: "eno1"

  config.vm.provision "shell", inline: <<-SHELL

  yum -y install net-tools telnet wireshark htop bash-completion vim

  yum -y update

  SHELL
end
