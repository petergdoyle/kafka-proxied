Vagrant.configure("2") do |config|

  config.vm.box = "petergdoyle/CentOS-7-x86_64-Minimal-1511"
  config.ssh.insert_key = false
  config.vm.network "forwarded_port", guest: 3000, host: 3000, host_ip: "0.0.0.0", id: "http service port", auto_correct: true
  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]
    vb.memory = "1024"
    vb.cpus = 2
  end

  config.vm.hostname = "kafka-proxied.cleverfishsoftware.com"
  #config.vm.network "public_network", ip: "192.168.1.84", bridge: "eno1"

  config.vm.provision "shell", inline: <<-SHELL

  yum -y install net-tools telnet wireshark htop bash-completion vim jq

  yum -y update

  SHELL
end
