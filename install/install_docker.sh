#!/bin/sh
. ../common.sh

if [[ $EUID -ne 0 ]]; then
  display_error "This script must be run as root"
  exit 1
fi

eval 'docker --version' > /dev/null 2>&1
if [ $? -eq 127 ]; then
  display_info "installing docker and docker-compose..."

  yum -y remove docker docker-common  docker-selinux docker-engine
  yum -y install yum-utils device-mapper-persistent-data lvm2
  yum-config-manager     --add-repo     https://download.docker.com/linux/centos/docker-ce.repo
  rm -fr /etc/yum.repos.d/docker.repo
  yum-config-manager --enable docker-ce-edge
  yum-config-manager --enable docker-ce-test
  yum -y makecache fast
  yum -y install docker-ce

  systemctl start docker
  systemctl enable docker
  groupadd docker

  yum -y install python-pip
  pip install --upgrade pip
  pip install -U docker-compose

else
  display_info "docker and docker-compose already installed"
fi

display_info "Users that run docker will now be added to the docker group. Those users must logout/login for group permissions to take effect " -i "" rsp
while true; do
  read -e -p "Enter a user to be added to the docker group (ctl+c to quit): " -i "$user" user
  usermod -aG docker $user
  sleep 1
  echo "user $user added to docker group"
  user=""
done
