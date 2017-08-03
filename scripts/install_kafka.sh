#!/bin/sh
. ./common.sh

if [ -d $kafka_installation_dir ]; then
  install_anyway="n"
  prompt="It appears kafka is already installed at $kafka_installation_dir, Install it again (y/n)? "
  default_value="$install_anyway"
  read -e -p "$prompt" -i "$default_value" install_anyway
  if [ "$install_anyway" != "y" ]; then
    exit 0
  fi
fi

if [ ! -d "$kafka_base_location" ]; then
 mkdir -pv $kafka_base_location
fi

downloadable="kafka_$scala_version-$kafka_version.tgz"
download_url="http://www-us.apache.org/dist/kafka/$kafka_version/$downloadable"
display_info "downloading $download_url to $kafka_base_location..."
kafka_home="$kafka_base_location/default"

if [ -d $kafka_home ]; then
  rm -v $kafka_home
fi

curl -O $download_url \
&& tar -xvf $downloadable -C $kafka_base_location \
&& rm -f $downloadable \
&& ln -s $kafka_base_location/kafka_$scala_version-$kafka_version $kafka_home

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

display_info "Kafka $kafka_version is now installed at $kafka_installation_dir and symlinked at $kafka_base_location/default"

display_info "Kafka configuration files are located at $kafka_base_location/config"

display_info "Kafka console logs are located at $kafka_base_location/logs"

display_info "Log out and log back in to set the KAFKA_HOME env variable for running other scripts OR source your ~/.bash_profile now."
