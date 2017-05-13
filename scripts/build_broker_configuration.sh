#!/bin/sh
cd $(dirname $0)

node_name=`hostname |grep -io broker[0-9] |awk '{print tolower($0)}'| grep '.*'`
if [ $? -eq 1 ]; then
  "It doesn't seem like you are on a machine named appropriately for a broker. Cannot continue"
  exit 1
fi
host_name=`hostname| cut -d"." -f1`

kafka_version="10.0.1"
read -e -p "Enter the kafka version: " -i "$kafka_version" kafka_version

broker_config_file=$node_name.properties
cp config/broker-template-$kafka_version.properties $broker_config_file

broker_id=`echo $node_name |grep -Eo '[0-9]'`
sed -i "s/broker.id=.*/zbroker.id=$broker_id/g" $broker_config_file

zk_host_port='192.168.60.100:2181'
read -e -p "Enter the zookeeper host/port: " -i "$zk_host_port" zk_host_port
sed -i "s/zookeeper.connect=.*/zookeeper.connect=$zk_host_port/g" $broker_config_file

read -e -p "Enter Kafka Log Retention Hours: " -i "1" kafka_log_retention_hrs
read -e -p "Enter Kafka Log Retention Size (Mb): " -i "25" kafka_log_retention_size_mb
kafka_log_retention_size=$((1024*1024*$kafka_log_retention_size_mb))
sed -i "s/log.retention.hours=.*/zlog.retention.hours=$kafka_log_retention_hrs/g" $broker_config_file
sed -i "s/log.retention.bytes=.*/zlog.retention.bytes=$kafka_log_retention_size/g" $broker_config_file

advertised_listeners="PLAINTEXT://localhost:9091, PLAINTEXT://$host_name:9091, PLAINTEXT://public_server:19091"
read -e -p "Enter Kafka advertised.listeners: " -i "$advertised_listeners" advertised_listeners


mirror_maker_zookeeper_connect=$zk_host_port
read -e -p "Enter Kafka zookeeper_connect for kafka_mirror_maker (consumers): " -i "$mirror_maker_zookeeper_connect" mirror_maker_zookeeper_connect
sed -i "s/log.retention.bytes=.*/zlog.retention.bytes=$kafka_log_retention_size/g" $broker_config_file
bootstrap.servers

# mirror_maker_bootstrap_servers=`echo $advertised_listeners |sed 's#PLAINTEXT://##g'`
mirror_maker_bootstrap_server="localhost:9091"
read -e -p "Enter Kafka bootstrap server for kafka_mirror_maker (producer): " -i "$mirror_maker_bootstrap_server" mirror_maker_bootstrap_server
