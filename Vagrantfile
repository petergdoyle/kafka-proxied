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
192.168.60.100  kafka-cluster-zookeeper1.vbx zookeeper1
192.168.60.101  kafka-cluster-broker1.vbx broker1
192.168.60.102  kafka-cluster-broker2.vbx broker2
EOF
    fi

    # install java on all nodes
    java -version > /dev/null 2>&1
    if [ $? -eq 127 ]; then
      mkdir -p /usr/java \
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

    # install kafka on all nodes
    kafka_version='kafka_2.11-0.10.0.1'
    kafka_base_location="/usr/kafka"
    if [ ! -d "$kafka_base_location/$kafka_version" ]; then
      mkdir -p $kafka_base_location \
      && echo "downloading $kafka_version..."

      curl -O http://www-us.apache.org/dist/kafka/0.10.0.1/kafka_2.11-0.10.0.1.tgz \
      && tar -xvf kafka_2.11-0.10.0.1.tgz -C $kafka_base_location \
      && rm -f kafka_2.11-0.10.0.1.tgz \
      && ln -s $kafka_base_location/kafka_2.11-0.10.0.1 $kafka_base_location/default

      export KAFKA_HOME=$kafka_base_location/default
      cat >/etc/profile.d/kafka.sh <<-EOF
export KAFKA_HOME=$KAFKA_HOME
EOF
      mkdir -p $kafka_base_location/kafka_2.11-0.10.0.1/logs \
      && chmod 1777 $kafka_base_location/kafka_2.11-0.10.0.1/logs

    else
      echo -e "\e[7;44;96m*$kafka_version already appears to be installed. skipping.\e[0m"
    fi

SHELL


  config.vm.define "zookeeper1" do |zookeeper1|
    zookeeper1.vm.hostname = "kafka-cluster-zookeeper1.vbx"
    zookeeper1.vm.network "private_network", ip: "192.168.60.100"
    zookeeper1.vm.network "forwarded_port", guest: 2181, host: 12181, host_ip: "0.0.0.0", id: "zookeeper1 node", auto_correct: true
  end
  config.vm.define "broker1" do |broker1|
    broker1.vm.hostname = "kafka-cluster-broker1.vbx"
    broker1.vm.network "private_network", ip: "192.168.60.101"
    broker1.vm.network "forwarded_port", guest: 9091, host: 19091, host_ip: "0.0.0.0", id: "broker1 node", auto_correct: true
  end
  config.vm.define "broker2" do |broker2|
    broker2.vm.hostname = "kafka-cluster-broker2.vbx"
    broker2.vm.network "private_network", ip: "192.168.60.102"
    broker2.vm.network "forwarded_port", guest: 9092, host: 19092, host_ip: "0.0.0.0", id: "broker2 node", auto_correct: true
  end


end
