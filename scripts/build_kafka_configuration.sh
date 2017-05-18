#!/bin/sh
# cd $(dirname $0)
. ./common.sh

DIR=`dirname $0`

if [ $? -eq 1 ]; then
  node_name=$host_name
  read -e -p "Cannot determine node name. Please supply a value to name this node: " -i "$node_name" node_name
fi
kafka_version="10.0.1"
read -e -p "Confirm the kafka version: " -i "$kafka_version" kafka_version
broker_config_file="$DIR/config/$node_name-broker.properties"
zookeeper_config_file="$DIR/config/$node_name-zookeeper.properties"
mm_producer_config_file="$DIR/config/$node_name-mm_producer.properties"
mm_consumer_config_file="$DIR/config/$node_name-mm_consumer.properties"

function create_zookeeper_config() {
  cp -vf $DIR/config/$kafka_version/zookeeper-template.properties $zookeeper_config_file
  configure_zookeeper
  sed -i "s/clientPort=.*/clientPort=$zk_port/g" $zookeeper_config_file
  sudo cp -vf $zookeeper_config_file $KAFKA_HOME/default/config/
}

function configure_zookeeper() {
  zk_host='192.168.60.100'
  read -e -p "Enter the zookeeper host: " -i "$zk_host" zk_host
  zk_port='2181'
  read -e -p "Enter the zookeeper host port: " -i "$zk_port" zk_port
  zk_host_port=$zk_host:$zk_port
}

function create_broker_config() {
  cp -vf $DIR/config/$kafka_version/broker-template.properties $broker_config_file
  configure_broker
}

function configure_broker() {

  broker_id=`echo $node_name |grep -o '[0-9:]*'`
  number_regex='^[0-9]+$'
  if ! [[ "$broker_id" =~ $number_regex ]]; then
    read -e -p "Enter an appropriate broker id (must be numeric and unique per server): " -i "1" broker_id
  fi
  sed -i "s/broker.id=.*/broker.id=$broker_id/g" $broker_config_file

  broker_port="9091"
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

  read -e -p "Enter Kafka Log Retention Hours: " -i "1" kafka_log_retention_hrs
  read -e -p "Enter Kafka Log Retention Size (Mb): " -i "25" kafka_log_retention_size_mb
  kafka_log_retention_size=$((1024*1024*$kafka_log_retention_size_mb))
  sed -i "s/log.retention.hours=.*/log.retention.hours=$kafka_log_retention_hrs/g" $broker_config_file
  sed -i "s/log.retention.bytes=.*/log.retention.bytes=$kafka_log_retention_size/g" $broker_config_file

  sudo cp -vf $broker_config_file $KAFKA_HOME/default/config/
}

function create_mirror_maker_config() {
  cp -vf $DIR/config/$kafka_version/mm_producer-template.properties $mm_producer_config_file
  cp -vf $DIR/config/$kafka_version/mm_consumer-template.properties $mm_consumer_config_file
  configure_mirror_maker
}

function configure_mirror_maker() {

  configure_zookeeper
  mirror_maker_zookeeper_connect=$zk_host_port
  read -e -p "Enter Kafka zookeeper_connect for kafka_mirror_maker (consumers): " -i "$mirror_maker_zookeeper_connect" mirror_maker_zookeeper_connect
  sed -i "s/zookeeper.connect=.*/zookeeper.connect=$mirror_maker_zookeeper_connect/g" $mm_consumer_config_file
  sed -i "s/group.id=.*/group.id=$host_name-mirrormaker-group-1/g" $mm_consumer_config_file
  sudo cp -vf $mm_consumer_config_file $KAFKA_HOME/default/config/

  # mirror_maker_bootstrap_servers=`echo $advertised_listeners |sed 's#PLAINTEXT://##g'`
  mirror_maker_bootstrap_server="localhost:9091"
  read -e -p "Enter Kafka bootstrap server for kafka_mirror_maker (producer): " -i "$mirror_maker_bootstrap_server" mirror_maker_bootstrap_server
  sed -i "s/bootstrap.servers=.*/bootstrap.servers=$mirror_maker_bootstrap_server/g" $mm_producer_config_file
  sudo cp -vf $mm_producer_config_file $KAFKA_HOME/default/config/

}
