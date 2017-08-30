#!/bin/sh
. ./common.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

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

  broker_port="909$i"
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
    truststore_location=$PWD/$(echo $mirror_maker_bootstrap_server |cut -d: -f1).truststore.jks
    while true; do
      read -e -p "Specify the truststore location: " -i "$truststore_location" truststore_location
      if [ -f $truststore_location ]; then
        break
      else
        display_error "Specified file $truststore_location does not exist"
      fi
    done

    truststore_password="majiic"
    read -e -p "Specify the truststore password: " -i "$truststore_password" truststore_password
    sed -i "s/#security.protocol/security.protocol/g" $mm_consumer_config_file
    sed -i "s?#ssl.truststore.location=#REPLACE#?ssl.truststore.location=$truststore_location?g" $mm_consumer_config_file
    sed -i "s/#ssl.truststore.password=#REPLACE#/ssl.truststore.password=$truststore_password/g" $mm_consumer_config_file

  fi

  # mirror_maker_bootstrap_servers=`echo $advertised_listeners |sed 's#PLAINTEXT://##g'`
  mirror_maker_bootstrap_server="localhost:9091"
  read -e -p "Enter Kafka bootstrap server for kafka_mirror_maker to put data to (producer config): " -i "$mirror_maker_bootstrap_server" mirror_maker_bootstrap_server
  sed -i "s/bootstrap.servers=.*/bootstrap.servers=$mirror_maker_bootstrap_server/g" $mm_producer_config_file

  response='n'
  read -e -p "Do you need to configure SSL for this Kafka bootstrap server (y/n): " -i "$response" response
  if [ "$response" == "y" ]; then
    truststore_location=$PWD/$(echo $mirror_maker_bootstrap_server |cut -d: -f1).truststore.jks
    while true; do
      read -e -p "Specify the truststore location: " -i "$truststore_location" truststore_location
      if [ -f $truststore_location ]; then
        break
      else
        display_error "Specified file $truststore_location does not exist"
      fi
    done

    truststore_password="majiic"
    read -e -p "Specify the truststore password: " -i "$truststore_password" truststore_password
    sed -i "s/#security.protocol/security.protocol/g" $mm_producer_config_file
    sed -i "s/#ssl.truststore.location=#REPLACE#/ssl.truststore.location=$truststore_location/g" $mm_producer_config_file
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
