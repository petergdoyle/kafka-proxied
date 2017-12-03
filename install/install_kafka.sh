 #!/bin/sh
 . ../kafka/kafka_common.sh

java -version > /dev/null 2>&1
if [ $? -eq 127 ]; then
  display_error "Jdk8 is not installed. Install Jdk8"
  exit 1
fi

kafka_available_versions=`find $kafka_config_dir/* -type d| sed 's#.*/##'| sed ':a;N;$!ba;s/\n/, /g'`
kafka_default_version=`find $kafka_config_dir/* -type d| sed 's#.*/##'| head -n 1`

prompt="Please confirm kafka version. Current version is $kafka_version.\nSelect one of:\n($kafka_available_versions):"
echo "kafka_installation_dir: $kafka_installation_dir"

while true; do
  read -e -p "$(echo -e $prompt) " -i "$kafka_default_version" kafka_version
  if [ ! -d $kafka_config_dir/$kafka_version ]; then
    display_error "kafka version $kafka_version is not supported. Please select another version."
  else
    break
  fi
done
set_kafka_variables

if [ ! -d "$kafka_base_location" ]; then
 mkdir -pv $kafka_base_location
fi

downloadable="kafka_$scala_version-$kafka_version.tgz"
kafka_link_file=$kafka_config_dir/$kafka_version/link
if [ ! -f $kafka_link_file ]; then
  display_error "Cannot find a link file in location $kafka_config_dir/$kafka_version/link. Add a link file that contains the downloadable kafka url specific to $downloadable. Cannot continue"
  exit 1
fi
download_url=`cat $kafka_link_file`
display_info "downloading $download_url to $kafka_base_location..."

if ! `validate_url $download_url`; then
  display_error "Bad url specified as $download_url. Server returned $response_code. Check link. Cannot continue"
  exit 1
fi

if [ -d $kafka_installation_dir ]; then #either relink it or install it again

  # if [ ! "`readlink $kafka_home`" -ef "$kafka_installation_dir" ]; then
  #   prompt="It appears kafka is already installed at $kafka_installation_dir but it is not linked correctly `readlink $kafka_home`. Do you want to just relink it (y/n)? "
  #   default_value="y"
  #   read -e -p $prompt -i "$default_value" relink_only
  #   if [ "$relink_only" == "y" ]; then
  #     rm -v $kafka_home
  #     ln -s $kafka_installation_dir $kafka_home
  #   fi
  # fi

  install_anyway="n"
  prompt="It appears kafka is already installed at $kafka_installation_dir, Install it again (y/n)? "
  default_value="$install_anyway"
  read -e -p "$(echo -e $prompt $cmd ) " -i "$default_value" install_anyway
  if [ "$install_anyway" != "y" ]; then
    exit 0
  fi
  if [ -L $kafka_home ]; then
    rm -fv $kafka_home
  fi

else

  # install and link
  if [ -L $kafka_home ]; then
    rm -fv $kafka_home
  fi
  curl -O $download_url \
  && tar -xvf $downloadable -C $kafka_base_location \
  && rm -f $downloadable

fi

ln -s $kafka_installation_dir $kafka_home

export KAFKA_HOME=$kafka_home
if ! grep -q KAFKA_HOME ~/.bash_profile; then
  cat >>~/.bash_profile <<-EOF
export KAFKA_HOME=$KAFKA_HOME
export PATH=\$PATH:\$KAFKA_HOME/bin
EOF
fi

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

display_info "Kafka $kafka_version configuration files are located at $kafka_runtime_config_dir"

display_info "Kafka $kafka_version console logs are located at $kafka_runtime_console_logs_dir"

display_warn "Kafka $kafka_version has been installed. Please source your ~/.bash_profile.sh."
