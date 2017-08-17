# -*- mode: ruby -*-

Vagrant.configure("2") do |config|

  config.vm.box = "petergdoyle/CentOS-7-x86_64-Minimal-1511"
  config.ssh.insert_key = false
  config.vm.box_check_update = false

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]
    vb.cpus=2
    vb.memory = "1024"
  end

  config.vm.define "engine1" do |engine1|
    engine1.vm.network :private_network, ip: "192.48.1.81"
    engine1.vm.network :forwarded_port, guest: 2181, host: 2181, host_ip: "0.0.0.0", id: "zookeeper 1", auto_correct: true
    engine1.vm.network :forwarded_port, guest: 9091, host: 9091, host_ip: "0.0.0.0", id: "broker 1", auto_correct: true
    engine1.vm.hostname = "kafka-cluster-engine1.vbx"
  end
  config.vm.define "engine2" do |engine2|
    engine2.vm.network :private_network, ip: "192.48.1.82"
    engine2.vm.network :forwarded_port, guest: 9092, host: 9092, host_ip: "0.0.0.0", id: "broker 2", auto_correct: true
    engine2.vm.hostname = "kafka-cluster-engine2.vbx"
  end
  config.vm.define "engine3" do |engine3|
    engine3.vm.network :private_network, ip: "192.48.1.83"
    engine3.vm.network :forwarded_port, guest: 9093, host: 9093, host_ip: "0.0.0.0", id: "broker 3", auto_correct: true
    engine3.vm.hostname = "kafka-cluster-engine3.vbx"
  end

  config.vm.provision "shell", inline: <<-SHELL

    yum -y install net-tools telnet wireshark htop bash-completion

    grep ^192.48.1 /etc/hosts> /dev/null 2>&1
    if [ $? -ne 0 ]; then
    cat >>/etc/hosts <<-EOF
192.48.1.81 kafka-cluster-engine1.vbx
192.48.1.81 kafka-cluster-engine2.vbx
192.48.1.81 kafka-cluster-engine3.vbx
EOF
    fi

  java -version > /dev/null 2>&1
  if [ $? -eq 127 ]; then
    echo "installing java-jdk-8..."
    mkdir -pv /usr/java
    yum install -y java-1.8.0-openjdk*
    java_home=`alternatives --list |grep jre_1.8.0_openjdk| awk '{print $3}'`
    ln -s "$java_home" /usr/java/default
    export JAVA_HOME=/usr/java/default
    cat >/etc/profile.d/java.sh <<-EOF
export JAVA_HOME=$JAVA_HOME
EOF

    export JAVA_HOME='/usr/java/default'
    cat >/etc/profile.d/java.sh <<-EOF
export JAVA_HOME=$JAVA_HOME
EOF

    # register all the java tools and executables to the OS as executables
    install_dir="$JAVA_HOME/bin"
    for each in $(find $install_dir -executable -type f) ; do
      name=$(basename $each)
      alternatives --install "/usr/bin/$name" "$name" "$each" 99999
    done

  else
    echo -e "\e[7;44;96m*java-jdk-8 already appears to be installed. skipping.\e[0m"
  fi

SHELL


end
