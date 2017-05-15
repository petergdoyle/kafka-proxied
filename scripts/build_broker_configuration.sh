#!/bin/sh
cd $(dirname $0)

host_name=`hostname| cut -d"." -f1`
node_name=`echo $host_name |grep -io broker[0-9] |awk '{print tolower($0)}'| grep '.*'`
if [ $? -eq 1 ]; then
  node_name=$host_name
fi
kafka_version="10.0.1"
read -e -p "Confirm the kafka version: " -i "$kafka_version" kafka_version
broker_config_file="config/$node_name-broker.properties"
zookeeper_config_file="config/$node_name-zookeeper.properties"
mm_producer_config_file="config/$node_name-mm_producer.properties"
mm_consumer_config_file="config/$node_name-mm_consumer.properties"
cp -vf config/$kafka_version/broker-template.properties $broker_config_file
cp -vf config/$kafka_version/zookeeper-template.properties $zookeeper_config_file
cp -vf config/$kafka_version/mm_producer-template.properties $mm_producer_config_file
cp -vf config/$kafka_version/mm_consumer-template.properties $mm_consumer_config_file


sed -i "s/broker.id=.*/broker.id=$node_name/g" $broker_config_file

broker_port='9091'
read -e -p "Enter the broker port: " -i "$broker_port" broker_port
listeners="PLAINTEXT://:$broker_port"
read -e -p "Enter the the address the socket server listens on (locally): " -i "$listeners" listeners
sed -i "s#listeners=.*#listeners=$listeners#g" $broker_config_file

advertised_listeners="PLAINTEXT://localhost:$broker_port, PLAINTEXT://$host_name:$broker_port, PLAINTEXT://public_server:1$broker_port"
read -e -p "Enter Kafka advertised.listeners (all proxies and ips that consumers try to connect with): " -i "$advertised_listeners" advertised_listeners
sed -i "s#advertised.listeners=.*#advertised.listeners=$advertised_listeners#g" $broker_config_file

zk_host='192.168.60.100'
read -e -p "Enter the zookeeper host: " -i "$zk_host" zk_host
zk_port='2181'
read -e -p "Enter the zookeeper host port: " -i "$zk_port" zk_port
sed -i "s/clientPort=.*/clientPort=$zk_port/g" $zookeeper_config_file

zk_host_port=$zk_host:$zk_port
sed -i "s/zookeeper.connect=.*/zookeeper.connect=$zk_host_port/g" $broker_config_file

read -e -p "Enter Kafka Log Retention Hours: " -i "1" kafka_log_retention_hrs
read -e -p "Enter Kafka Log Retention Size (Mb): " -i "25" kafka_log_retention_size_mb
kafka_log_retention_size=$((1024*1024*$kafka_log_retention_size_mb))
sed -i "s/log.retention.hours=.*/log.retention.hours=$kafka_log_retention_hrs/g" $broker_config_file
sed -i "s/log.retention.bytes=.*/log.retention.bytes=$kafka_log_retention_size/g" $broker_config_file

mirror_maker_zookeeper_connect=$zk_host_port
read -e -p "Enter Kafka zookeeper_connect for kafka_mirror_maker (consumers): " -i "$mirror_maker_zookeeper_connect" mirror_maker_zookeeper_connect
sed -i "s/zookeeper.connect=.*/zookeeper.connect=$mirror_maker_zookeeper_connect/g" $mm_consumer_config_file
sed -i "s/group.id=.*/group.id=$host_name-mirrormaker-group-1/g" $mm_consumer_config_file


# mirror_maker_bootstrap_servers=`echo $advertised_listeners |sed 's#PLAINTEXT://##g'`
mirror_maker_bootstrap_server="localhost:9091"
read -e -p "Enter Kafka bootstrap server for kafka_mirror_maker (producer): " -i "$mirror_maker_bootstrap_server" mirror_maker_bootstrap_server
sed -i "s/bootstrap.servers=.*/bootstrap.servers=$mirror_maker_bootstrap_server/g" $mm_producer_config_file
