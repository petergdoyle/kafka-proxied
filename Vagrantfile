Vagrant.configure("2") do |config|

  config.vm.box = "petergdoyle/CentOS-7-x86_64-Minimal-1511"
  config.ssh.insert_key = false

  config.vm.provider "virtualbox" do |vb|
    vb.customize ["modifyvm", :id, "--cpuexecutioncap", "80"]
    vb.memory = "512"
    vb.cpus = 1
  end

  config.vm.hostname = "kafka-proxied.cleverfishsoftware.com"
  #config.vm.network "public_network", ip: "192.168.1.84", bridge: "eno1"

  config.vm.provision "shell", inline: <<-SHELL

  yum -y install net-tools telnet wireshark htop bash-completion vim

  java -version > /dev/null 2>&1
  if [ $? -eq 127 ]; then
    mkdir -p /usr/java \
    && echo "installing openjdk..."

    yum install -y java-1.8.0-openjdk*

    java_home=`alternatives --list |grep jre_1.8.0_openjdk| awk '{print $3}'`
    mkdir -p /usr/java
    ln -s "$java_home" /usr/java/default
    export JAVA_HOME=/usr/java/default
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

  yum -y update

  SHELL
end
