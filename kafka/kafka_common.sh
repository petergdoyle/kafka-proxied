#!/bin/sh
. ../common.sh

host_name=`hostname| cut -d"." -f1`
node_name=`echo $host_name |grep -Eo "broker[0-9]|zookeeper[0-9]" |awk '{print tolower($0)}'| grep '.*'`
if [ "$node_name" == "" ]; then
  node_name=$host_name
fi

kafka_base_location=$local_kafka_dir
#first see if there is a symlink to some kafka installation
kafka_home="$kafka_base_location/default"
kafka_version=`readlink -f $kafka_home | awk -F- '{print $NF}'`
if [[ -z $kafka_version || ! -L $kafka_home ]]; then
  kafka_version='unknown'
  display_warn "Kafka version is 'unknown'. Install kafka now."
else
  display_info "Kafka version is '$kafka_version'."
fi
scala_version="2.11"


function set_kafka_variables() {

  kafka_installation_dir="$kafka_base_location/kafka_$scala_version-$kafka_version"

  # kafka_runtime_logs_dir="$kafka_base_location/default/logs"
  kafka_runtime_logs_dir="$kafka_installation_dir/logs"
  kafka_controller_log_file="$kafka_runtime_logs_dir/controller.log"

  # kafka_runtime_console_logs_dir="$kafka_base_location/logs"
  kafka_runtime_console_logs_dir="$kafka_installation_dir/logs"
  broker_runtime_console_log_file="$kafka_runtime_console_logs_dir/$node_name-broker-console.log"
  zookeeper_runtime_console_log_file="$kafka_runtime_console_logs_dir/$node_name-zookeeper-console.log"
  mm_runtime_console_log_file="$kafka_runtime_console_logs_dir/$node_name-mirror-maker-console.log"

  kafka_templates_config_dir="$kafka_config_dir/$kafka_version"
  broker_config_template_file="$kafka_templates_config_dir/broker-template.properties"
  zookeeper_config_template_file="$kafka_templates_config_dir/zookeeper-template.properties"
  mm_producer_config_template_file="$kafka_templates_config_dir/mm_producer-template.properties"
  mm_consumer_config_template_file="$kafka_templates_config_dir/mm_consumer-template.properties"
  consumer_ssl_config_template_file="$kafka_templates_config_dir/console-consumer-ssl-template.properties"
  producer_ssl_config_template_file="$kafka_templates_config_dir/console-producer-ssl-template.properties"

  # kafka_runtime_config_dir="$kafka_base_location/config"
  kafka_runtime_config_dir="$kafka_installation_dir/config"
  broker_config_file="$kafka_runtime_config_dir/$node_name-broker.properties"
  zookeeper_config_file="$kafka_runtime_config_dir/$node_name-zookeeper.properties"
  mm_producer_config_file="$kafka_runtime_config_dir/$node_name-mm_producer.properties"
  mm_consumer_config_file="$kafka_runtime_config_dir/$node_name-mm_consumer.properties"
  consumer_ssl_config_file="$kafka_runtime_config_dir/console-consumer-ssl.properties"
  producer_ssl_config_file="$kafka_runtime_config_dir/console-producer-ssl.properties"

  zookeeper_process_running_cmd="ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'"

  kafka_broker_logs_dir='/tmp/kafka-logs'
  zookeeper_logs_dir='/tmp/zookeeper'
}

set_kafka_variables

function verify_config_templates() {
  return_code=0
  if [ ! -f $broker_config_template_file ]; then
    display_error "missing template file $broker_config_template_file"
    return_code=1
  fi
  if [ ! -f $zookeeper_config_template_file ]; then
    display_error "missing template file $zookeeper_config_template_file"
    return_code=1
  fi
  if [ ! -f $mm_producer_config_template_file ]; then
    display_error "missing template file $mm_producer_config_template_file"
    return_code=1
  fi
  if [ ! -f $mm_consumer_config_template_file ]; then
    display_error "missing template file $mm_consumer_config_template_file"
    return_code=1
  fi
  if [ ! -f $consumer_ssl_config_template_file ]; then
    display_warn "missing template file $consumer_ssl_config_template_file"
    return_code=0
  fi
  if [ ! -f $producer_ssl_config_template_file ]; then
    display_warn "missing template file $producer_ssl_config_template_file"
    return_code=0
  fi
  return $return_code
}

function check_kafka_installed() {
  if [ "$(ls -A $kafka_base_location)" ]; then
    echo "true"
    #  echo "Take action $DIR is not Empty"
  else
    # echo "$DIR is Empty"
    echo "false"
  fi
}

function check_env() {

  if [ -z ${KAFKA_HOME+x} ]; then
    prompt="Kafka does not appear to be installed. Install Kafka locally? "
    default_value="y"
    read -e -p "$prompt" -i $default_value response
    if [ "$response" != 'y' ]; then
     echo "Cannot continue"
     exit 1
    fi
  fi

}

# ZK_PIDS=`ps ax | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`
# BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`
# MM_PIDS=`ps ax | grep -i MirrorMaker | grep -v grep | awk '{print $1}'`

function check_zookeper_status() {

  ZK_PIDS=`ps ax | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`

  [[ ! -z $ZK_PIDS ]] \
    && display_info "Zookeeper process(es) running:\n$ZK_PIDS" \
    || display_warn "Zookeeper process(es) running: No Zookeeper processes running"

}

function check_broker_status() {

  BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`

  [[ ! -z $BKR_PIDS ]] \
    && display_info "Kafka Broker process(es) running:\n$BKR_PIDS" \
    || display_warn "Kafka Broker process(es) running: No Kafka Broker processes running"

}

function check_mirror_maker_status() {

  MM_PIDS=`ps ax | grep -i MirrorMaker | grep -v grep | awk '{print $1}'`

  [[ ! -z $MM_PIDS ]] \
    && display_info "Mirror-Maker process(es) running:\n$MM_PIDS" \
    || display_warn "Mirror-Maker process(es) running: No Mirror-Maker processes running"

}


function show_cluster_state() {

  display_H1 "Host Details:"$RESET
  display_info "full host name: `hostname`"
  display_info "host name: $host_name"
  display_info "kafka cluster node_name: $node_name"
  display_info "network interfaces: `ifconfig |grep 'inet '| awk '{print $2}'| tr '\n' '  '|sed '$s/.$//'`"
  display_info "cpu info: `grep '^model name' /proc/cpuinfo | awk '!a[$0]++'| sed -e 's/.*: //'` (`grep -c ^processor /proc/cpuinfo`)"
  display_break

  display_H1 "Kafka Details:"$RESET
  display_info "kafka version: $kafka_version"
  [[ -d $kafka_installation_dir ]] \
  && display_info "kafka installation location: $kafka_installation_dir" \
  || display_warn "kafka installation location: Not installed"
  [[ ! -z $KAFKA_HOME ]] \
  && display_info "KAFKA_HOME: $KAFKA_HOME" \
  || display_warn "KAFKA_HOME: Not set ==> Please run install_kafka.sh or source ~/.bash_profile if installed kafka and did not do so."

  if [ -d $kafka_home ]; then #kafka is installed
    if [ "`readlink $kafka_base_location/default`" -ef "$kafka_installation_dir" ]; then
      display_info "The kafka version $kafka_version matches what is linked at $kafka_home "
    else
      display_error "The kafka version $kafka_version does not match with what is linked at `readlink $kafka_home` ==> Please run install_kafka.sh or change the kafka_version in common.sh";
    fi
  fi

  [[ -d $kafka_runtime_logs_dir ]] \
  && display_info "kafka runtime logs dir: $kafka_runtime_logs_dir" \
  || display_warn "kafka runtime logs dir: $kafka_runtime_logs_dir *Has not been created yet!"
  display_break

  display_H1 "Kafka Configuration:"
  display_info "kafka runtime configuration location: $kafka_runtime_config_dir"

  if [ `find $kafka_runtime_config_dir -name '*broker*'| wc -l` -gt 0 ]; then
    for each in `find $kafka_runtime_config_dir -name '*broker*'`; do
      display_info "kafka broker config file found : $each"
    done
  else
    display_warn "No kafka broker config files found. *Has not been created yet!"
  fi

  if [ `find $kafka_runtime_config_dir -name '*zookeeper*'| wc -l` -gt 0 ]; then
    for each in `find $kafka_runtime_config_dir -name '*zookeeper*'`; do
      display_info "kafka zookeeper config file found: $each"
    done
  else
    display_warn "No kafka zookeeper config files found. *Has not been created yet!"
  fi

  [[ -f $mm_producer_config_file ]] \
  && display_info "kafka mirror-maker producer config file: $mm_producer_config_file" \
  || display_warn "kafka mirror-maker producer config file: $mm_producer_config_file *Has not been created yet!"
  [[ -f $mm_consumer_config_file ]] \
  && display_info "kafka mirror-maker consumer config file: $mm_consumer_config_file" \
  || display_warn "kafka mirror-maker consumer config file: $mm_consumer_config_file *Has not been created yet!"
  [[ -f $consumer_ssl_config_file ]] \
  && display_info "kafka mirror-maker consumer config file: $consumer_ssl_config_file" \
  || display_warn "kafka mirror-maker consumer config file: $consumer_ssl_config_file *Has not been created yet!"
  [[ -f $producer_ssl_config_file ]] \
  && display_info "kafka mirror-maker consumer config file: $producer_ssl_config_file" \
  || display_warn "kafka mirror-maker consumer config file: $producer_ssl_config_file *Has not been created yet!"
  display_break

  display_H1 "Kafka Configuration Templates:"
  display_info "kafka configuration templates location: $kafka_templates_config_dir"
  display_info "kafka broker config template file: $broker_config_template_file"
  display_info "kafka zookeeper config template file: $zookeeper_config_template_file"
  display_info "kafka mirror-maker producer config template file: $mm_producer_config_template_file"
  display_info "kafka mirror-maker consumer config template file: $mm_consumer_config_template_file"
  display_info "kafka console-consumer ssl config template file: $consumer_ssl_config_template_file"
  display_info "kafka console-producer ssl config template file: $producer_ssl_config_template_file"
  display_break

  display_H1 "Kafka Logs:"
  [[ -d $kafka_broker_logs_dir ]] \
  && display_info "kafka persistent broker logs location: $kafka_broker_logs_dir" \
  || display_warn "kafka persistent broker logs location: $kafka_broker_logs_dir *Has not been created yet!"
  [[ -d $zookeeper_logs_dir ]] \
  && display_info "kafka persistent zookeeper logs location: $zookeeper_logs_dir" \
  || display_warn "kafka persistent zookeeper logs location: $zookeeper_logs_dir *Has not been created yet!"
  [[ -d $kafka_runtime_console_logs_dir ]] \
  && display_info "kafka persistent runtime logs directory: $kafka_runtime_console_logs_dir" \
  || display_warn "kafka persistent logs directory: $kafka_runtime_console_logs_dir *Has not been created yet!"

  # display_info "kafka broker runtime console log: $broker_runtime_console_log_file"
  # display_warn "kafka broker runtime console log: $broker_runtime_console_log_file *Has not been created yet!"
  #
  # display_info "kafka zookeeper runtime console log: $zookeeper_runtime_console_log_file"
  # display_warn "kafka zookeeper runtime console log: $zookeeper_runtime_console_log_file *Has not been created yet!"

  if [ `find $kafka_runtime_console_logs_dir -name '*broker*'| wc -l` -gt 0 ]; then
    for each in `find $kafka_runtime_console_logs_dir -name '*broker*'`; do
      display_info "kafka broker console log file found : $each"
    done
  else
    display_warn "No kafka broker console log files found. *Has not been created yet!"
  fi

  if [ `find $kafka_runtime_console_logs_dir -name '*zookeeper*'| wc -l` -gt 0 ]; then
    for each in `find $kafka_runtime_console_logs_dir -name '*zookeeper*'`; do
      display_info "kafka zookeeper console log file found: $each"
    done
  else
    display_warn "No kafka zookeeper console log files found. *Has not been created yet!"
  fi

  [[ -f $mm_runtime_console_log_file ]] \
  && display_info "kafka mirror-maker runtime console log: $mm_runtime_console_log_file" \
  || display_warn "kafka mirror-maker runtime console log: $mm_runtime_console_log_file *Has not been created yet!"
  display_break

  display_H1 "Kafka Cluster Status:"
  check_zookeper_status
  check_broker_status
  check_mirror_maker_status

}

function configure_zookeeper() {
  zk_host='localhost'
  read -e -p "Enter the zookeeper host: " -i "$zk_host" zk_host
  zk_port='2181'
  read -e -p "Enter the zookeeper host port: " -i "$zk_port" zk_port
  zk_host_port=$zk_host:$zk_port
}

function configure_broker() {

  # broker_id=`echo $node_name |grep -o '[0-9:]*'`
  # number_regex='^[0-9]+$'
  # if ! [[ "$broker_id" =~ $number_regex ]]; then
  #   read -e -p "Enter an appropriate broker id (must be numeric and unique per server): " -i "1" broker_id
  # fi
  broker_id=$1
  sed -i "s/broker.id=.*/broker.id=$broker_id/g" $broker_config_file
  sed -i "s#log.dirs=.*#log.dirs=/tmp/kafka-logs/$broker_id#g" $broker_config_file

  broker_port="909$1"
  read -e -p "Enter the broker port: " -i "$broker_port" broker_port
  listeners="PLAINTEXT://:$broker_port"
  read -e -p "Enter the the address the socket server listens on (locally): " -i "$listeners" listeners
  sed -i "s#listeners=.*#listeners=$listeners#g" $broker_config_file

  advertised_listeners="PLAINTEXT://public_server:1$broker_port"
  proxy_external="n"
  read -e -p "Will the broker be accessed by a proxy or external public server (y/n)?: " -i "$proxy_external" proxy_external
  if [ "$proxy_external" != "n" ]; then
    read -e -p "Enter Kafka advertised.listeners (all proxies and ips comma separated): " -i "$advertised_listeners" advertised_listeners
    sed -i "s#advertised.listeners=.*#advertised.listeners=$advertised_listeners#g" $broker_config_file
  fi

  configure_zookeeper
  sed -i "s/zookeeper.connect=.*/zookeeper.connect=$zk_host_port/g" $broker_config_file

  max_message_size_mb='1'
  read -e -p "Specify maximum message size the broker will accept (message.max.bytes) in MB. Default value (1 MB): " -i $max_message_size_mb max_message_size_mb
  max_message_size=$((1024*1024*$max_message_size_mb))
  sed -i "s#message.max.bytes=.*#message.max.bytes=$max_message_size#g" $broker_config_file

  read -e -p "You must make sure that the Kafka consumer configuration parameter fetch.message.max.bytes is specified as at least $max_message_size!" -i "" bla

  log_segment_size_gb='1'
  read -e -p "Specify Size of a Kafka data file (log.segment.bytes) in GiB. Must be larger than any single message. Default value: (1 GiB): " -i $log_segment_size_gb log_segment_size_gb
  log_segment_size=$((1024*1024*1024*$log_segment_size_gb))
  sed -i "s#log.segment.bytes=.*#log.segment.bytes=$log_segment_size#g" $broker_config_file

  read -e -p "Enter Kafka Log default Retention Hours: " -i "1" kafka_log_retention_hrs
  read -e -p "Enter Kafka Log default Retention Size (Mb): " -i "25" kafka_log_retention_size_mb
  kafka_log_retention_size=$((1024*1024*$kafka_log_retention_size_mb))
  sed -i "s/log.retention.hours=.*/log.retention.hours=$kafka_log_retention_hrs/g" $broker_config_file
  sed -i "s/log.retention.bytes=.*/log.retention.bytes=$kafka_log_retention_size/g" $broker_config_file

}

function create_mirror_maker_config() {
  if [ ! -d $kafka_runtime_config_dir ]; then
    mkdir -pv $kafka_runtime_config_dir
  fi

  if [ ! -d $kafka_runtime_console_logs_dir ]; then
    mkdir -pv $kafka_runtime_console_logs_dir
  fi
    if [ ! -f $mm_producer_config_template_file ]; then
      "cannot continue. no template file named $mm_producer_config_template_file exists"
      exit 1
    fi
  cp -vf $mm_producer_config_template_file $mm_producer_config_file
  cp -vf $mm_consumer_config_template_file $mm_consumer_config_file
  configure_mirror_maker
}

function configure_mirror_maker() {

# modified to use the new kafka api with broker specification rather than zookeeper

  # mirror_maker_zookeeper_connect="localhost:2181"
  # read -e -p "Enter Kafka zookeeper host:port for kafka_mirror_maker (consumer): " -i "$mirror_maker_zookeeper_connect" mirror_maker_zookeeper_connect
  # sed -i "s/zookeeper.connect=.*/zookeeper.connect=$mirror_maker_zookeeper_connect/g" $mm_consumer_config_file
  # sed -i "s/group.id=.*/group.id=$host_name-mirrormaker-group-1/g" $mm_consumer_config_file

  mirror_maker_bootstrap_server="remotehost:9091"
  read -e -p "Enter Kafka bootstrap server for kafka_mirror_maker to take data from (consumer config): " -i "$mirror_maker_bootstrap_server" mirror_maker_bootstrap_server
  sed -i "s/bootstrap.servers=.*/bootstrap.servers=$mirror_maker_bootstrap_server/g" $mm_consumer_config_file

  consumer_group=$node_name-mirrormaker-group-1
  read -e -p "Enter the consumer group name : " -i "$consumer_group" consumer_group
  sed -i "s/group.id=.*/group.id=$consumer_group/g" $mm_consumer_config_file


  response='n'
  read -e -p "Do you need to configure SSL for this Kafka bootstrap server (y/n): " -i "$response" response
  if [ "$response" == "y" ]; then
    keystore_file=$keystore_dir/$(echo $mirror_maker_bootstrap_server |cut -d: -f1).truststore.jks
    while true; do
      read -e -p "Specify the jks keystor file: " -i "$keystore_file" keystore_file
      if [ -f $keystore_file ]; then
        break
      else
        display_error "Specified file $keystore_file does not exist"
      fi
    done

    truststore_password="majiic"
    read -e -p "Specify the truststore password: " -i "$truststore_password" truststore_password
    sed -i "s/#security.protocol/security.protocol/g" $mm_consumer_config_file
    sed -i "s?#ssl.truststore.location=#REPLACE#?ssl.truststore.location=$keystore_file?g" $mm_consumer_config_file
    sed -i "s/#ssl.truststore.password=#REPLACE#/ssl.truststore.password=$truststore_password/g" $mm_consumer_config_file

  fi

  # mirror_maker_bootstrap_servers=`echo $advertised_listeners |sed 's#PLAINTEXT://##g'`
  mirror_maker_bootstrap_server="localhost:9091"
  read -e -p "Enter Kafka bootstrap server for kafka_mirror_maker to put data to (producer config): " -i "$mirror_maker_bootstrap_server" mirror_maker_bootstrap_server
  sed -i "s/bootstrap.servers=.*/bootstrap.servers=$mirror_maker_bootstrap_server/g" $mm_producer_config_file

  response='n'
  read -e -p "Do you need to configure SSL for this Kafka bootstrap server (y/n): " -i "$response" response
  if [ "$response" == "y" ]; then
    keystore_file=$PWD/$(echo $mirror_maker_bootstrap_server |cut -d: -f1).truststore.jks
    while true; do
      read -e -p "Specify the truststore location: " -i "$keystore_file" keystore_file
      if [ -f $keystore_file ]; then
        break
      else
        display_error "Specified file $keystore_file does not exist"
      fi
    done

    truststore_password="majiic"
    read -e -p "Specify the truststore password: " -i "$truststore_password" truststore_password
    sed -i "s/#security.protocol/security.protocol/g" $mm_producer_config_file
    sed -i "s/#ssl.truststore.location=#REPLACE#/ssl.truststore.location=$keystore_file/g" $mm_producer_config_file
    sed -i "s/#ssl.truststore.password=#REPLACE#/ssl.truststore.password=$truststore_password/g" $mm_producer_config_file

  fi


}

function cleanup_kafka() {


  local dir=$kafka_runtime_logs_dir
  local name="kafka runtime logs dir"
  if [ -d $dir ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "$name($dir) Exists and is not Empty";
    read -e -p "Destroy old console logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      rm -frv $kafka_runtime_logs_dir/*
    fi
  else
    display_info "$name($dir) Doesn't Exist or is Empty"
    if [ -d $dir ]; then
      mkdir -pv $kafka_runtime_logs_dir \
      && chmod 1777 $kafka_runtime_logs_dir
    fi
  fi

  local dir=$kafka_runtime_console_logs_dir
  local name="kafka runtime console logs dir"
  if [ -d $dir ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "$name($dir) Exists and is not Empty";
    read -e -p "Destroy old console logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      rm -frv $kafka_runtime_console_logs_dir/*
    fi
  else
    display_info "$name($dir) Doesn't Exist or is Empty"
    if [ -d $dir ]; then
      mkdir -pv $kafka_runtime_console_logs_dir \
      && chmod 1777 $kafka_runtime_console_logs_dir
    fi
  fi

  local dir=$kafka_runtime_config_dir
  local name="kafka runtime config dir"
  if [ -d $dir ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "$name($dir) Exists and is not Empty";
    read -e -p "Destroy old kafka configuration files? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      rm -frv $kafka_runtime_config_dir/*
    fi
  else
    display_info "$name($dir) Doesn't Exist or is Empty"
    if [ -d $dir ]; then
      mkdir -pv $kafka_runtime_config_dir \
      && chmod 1777 $kafka_runtime_config_dir
    fi
  fi

  local dir=$kafka_broker_logs_dir
  local name="kafka broker logs dir"
  if [ -d $dir ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "$name($dir) Exists and is not Empty";
    read -e -p "Destroy old persistent Kafka Broker logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      rm -frv $kafka_broker_logs_dir
    fi
  else
    display_info "$name($dir) Doesn't Exist or is Empty"
    if [ -d $dir ]; then
      echo "Kafka brokers will create these on their own"
    fi
  fi

  local dir=$zookeeper_logs_dir
  local name="zookeeper logs dir"
  if [ -d $dir ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "$name($dir) Exists and is not Empty";
    read -e -p "Destroy old persistent Kafka Zookeeper logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      rm -frv $zookeeper_logs_dir
    fi
  else
    display_info "$name($dir) Doesn't Exist or is Empty"
    if [ -d $dir ]; then
      echo "Zookeper will create this on his own"
    fi
  fi

}

function capture_kafka() {

  kafka_archive_name='kafka-capture.tar.gz'
  read -e -p "Name of the kafka state capture file? (y/n): " -i "$kafka_archive_name" kafka_archive_name
  kafka_archive_src=""

  local dir=$kafka_runtime_logs_dir
  local name="kafka runtime logs dir"
  if [ -d $dir ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "$name($dir) Exists and is not Empty";
    read -e -p "Capture old console logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      kafka_archive_src="$kafka_archive_src $kafka_runtime_logs_dir"
    fi
  else
    display_info "$name($dir) Doesn't Exist or is Empty"
  fi

  local dir=$kafka_runtime_console_logs_dir
  local name="kafka runtime console logs dir"
  if [ -d $dir ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "$name($dir) Exists and is not Empty";
    read -e -p "Capture old console logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      kafka_archive_src="$kafka_archive_src $kafka_runtime_console_logs_dir"
    fi
  else
    display_info "$name($dir) Doesn't Exist or is Empty"
  fi

  local dir=$kafka_runtime_config_dir
  local name="kafka runtime config dir"
  if [ -d $dir ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "$name($dir) Exists and is not Empty";
    read -e -p "Capture old kafka configuration files? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      kafka_archive_src="$kafka_archive_src $kafka_runtime_config_dir"
    fi
  else
    display_info "$name($dir) Doesn't Exist or is Empty"
  fi

  local dir=$kafka_broker_logs_dir
  local name="kafka broker logs dir"
  if [ -d $dir ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "$name($dir) Exists and is not Empty";
    read -e -p "Capture old persistent Kafka Broker logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      kafka_archive_src="$kafka_archive_src $kafka_broker_logs_dir"
    fi
  else
    display_info "$name($dir) Doesn't Exist or is Empty"
  fi

  local dir=$zookeeper_logs_dir
  local name="zookeeper logs dir"
  if [ -d $dir ] && [ ! -z "$(ls -A $dir)" ]; then
    echo "$name($dir) Exists and is not Empty";
    read -e -p "Capture old persistent Kafka Zookeeper logs? (y/n): " -i "y" response
    if [ "$response" == 'y' ]; then
      kafka_archive_src="$kafka_archive_src $zookeeper_logs_dir"
    fi
  else
    display_info "$name($dir) Doesn't Exist or is Empty"
  fi

  tar -czvf $kafka_archive_name $kafka_archive_src

}
