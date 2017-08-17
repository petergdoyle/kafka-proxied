#!/bin/sh
. ./common.sh


java -version > /dev/null 2>&1
if [ $? -eq 127 ]; then

  prompt="It appears java-jdk-8 is not installed. Do you want to install it (y/n)? "
  default_value="y"
  read -e -p "$(echo -e $BOLD$YELLOW$prompt $cmd $RESET)" -i "$default_value" install_java
  if [ "$install_java" != 'y' ]; then
    exit 0
  fi

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


if [ -d $kafka_installation_dir ]; then
  if [ ! "`readlink $kafka_home`" -ef "$kafka_installation_dir" ]; then
    prompt="It appears kafka is already installed at $kafka_installation_dir but it is not linked correctly `readlink $kafka_home`. Do you want to just relink it (y/n)? "
    default_value="y"
    read -e -p "$(echo -e $BOLD$YELLOW$prompt $cmd $RESET)" -i "$default_value" relink_only
    if [ "$relink_only" == "y" ]; then
      rm -v $kafka_home
      ln -s $kafka_installation_dir $kafka_home
    fi
  fi
  install_anyway="n"
  prompt="It appears kafka is already installed at $kafka_installation_dir, Install it again (y/n)? "
  default_value="$install_anyway"
  read -e -p "$(echo -e $BOLD$YELLOW$prompt $cmd $RESET)" -i "$default_value" install_anyway
  if [ "$install_anyway" != "y" ]; then
    exit 0
  fi
fi

if [ ! -d "$kafka_base_location" ]; then
 mkdir -pv $kafka_base_location
fi

if [ -d $kafka_home ]; then
  rm -v $kafka_home
fi

downloadable="kafka_$scala_version-$kafka_version.tgz"
download_url="http://www-us.apache.org/dist/kafka/$kafka_version/$downloadable"
display_info "downloading $download_url to $kafka_base_location..."

curl -O $download_url \
&& tar -xvf $downloadable -C $kafka_base_location \
&& rm -f $downloadable \
&& ln -s $kafka_installation_dir $kafka_home

if `grep KAFKA_HOME ~/.bash_profile` ; then
  # replace
  sed -i "s@export KAFKA_HOME=.*@export KAFKA_HOME="$kafka_home"@g" ~/.bash_profile
else
  # insert
 export KAFKA_HOME=$kafka_base_location/default
 cat >>~/.bash_profile <<-EOF
export KAFKA_HOME=$KAFKA_HOME
EOF
fi

cleanup_kafka

if [ ! -d $kafka_templates_config_dir ]; then #take a copy of the distribution configs
  mkdir -pv $kafka_templates_config_dir
  cp -v $kafka_installation_dir/config/* $kafka_templates_config_dir
fi

if [ ! -d $kafka_runtime_config_dir ]; then
  mkdir -pv $kafka_runtime_config_dir
fi
if [ ! -d $kafka_runtime_console_logs_dir ]; then
  mkdir -pv $kafka_runtime_console_logs_dir
fi

display_info "Kafka $kafka_version is now installed at $kafka_installation_dir and symlinked at $kafka_base_location/default"

display_info "Kafka configuration files are located at $kafka_runtime_config_dir"

display_info "Kafka console logs are located at $kafka_runtime_console_logs_dir"

display_info "Log out and log back in to set the KAFKA_HOME env variable for running other scripts OR source your ~/.bash_profile now."
