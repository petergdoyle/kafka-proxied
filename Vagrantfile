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

  config.vm.provision "shell", inline: <<-SHELL

      yum -y install net-tools telnet htop bash-completion

      grep ^192.168.60 /etc/hosts> /dev/null 2>&1
      if [ $? -ne 0 ]; then
    cat >>/etc/hosts <<-EOF
192.168.1.301 kafka-cluster-node1.vbx
192.168.1.302 kafka-cluster-node3.vbx
192.168.1.303 kafka-cluster-node3.vbx
EOF
    fi

    # install java on all nodes
    java -version > /dev/null 2>&1
    if [ $? -eq 127 ]; then
      mkdir -pv /usr/java \
      && echo "downloading java..."
      #install java jdk 8 from oracle
      # curl -O -L --header "Cookie: gpw_e24=http%3A%2F%2Fwww.oracle.com%2F; oraclelicense=accept-securebackup-cookie" \
      # "http://download.oracle.com/otn-pub/java/jdk/8u101-b13/jdk-8u101-linux-x64.tar.gz" \
      #   && tar -xvf jdk-8u101-linux-x64.tar.gz -C /usr/java \
      #   && ln -s /usr/java/jdk1.8.0_101/ /usr/java/default \
      #   && rm -f jdk-8u101-linux-x64.tar.gz

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
      echo -e "\e[7;44;96m*java already appears to be installed. skipping.\e[0m"
    fi

SHELL


  config.vm.define "node1" do |app|
    app.vm.hostname = "kafka-cluster-node1.vbx"
    app.vm.network "public_network", ip: "192.168.1.301"
    app.vm.network "forwarded_port", guest: 2181, host: 2181, host_ip: "0.0.0.0", id: "kfka_zkp_1", auto_correct: true
    app.vm.network "forwarded_port", guest: 9091, host: 9091, host_ip: "0.0.0.0", id: "kfka_bkr_1", auto_correct: true
  end
  config.vm.define "node2" do |app|
    app.vm.hostname = "kafka-cluster-node2.vbx"
    app.vm.network "public_network", ip: "192.168.1.302"
    app.vm.network "forwarded_port", guest: 9092, host: 9092, host_ip: "0.0.0.0", id: "kfka_bkr_2", auto_correct: true
  end
  config.vm.define "node3" do |app|
    app.vm.hostname = "kafka-cluster-node3.vbx"
    app.vm.network "public_network", ip: "192.168.1.303"
    app.vm.network "forwarded_port", guest: 9093, host: 9093, host_ip: "0.0.0.0", id: "kfka_bkr_3", auto_correct: true
  end




end
