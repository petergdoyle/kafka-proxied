#!/bin/sh
cd $(dirname $0)
. ./common.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

zk_host_port='localhost:2181'
read -e -p "Enter the zk host/port: " -i "$zk_host_port" zk_host_port

topic='hertz-edifact'
read -e -p "Enter the topic name: " -i "$topic" topic

partitions='1'
read -e -p "Enter the number of partitions: " -i "$partitions" partitions

replication_factor='1'
read -e -p "Enter the replication factor: " -i "$replication_factor" replication_factor

read -e -p "Enter topic retention time (hrs): " -i "1" kafka_topic_log_retention_hrs
kafka_topic_log_retention_ms=$((60*60*1000*$kafka_topic_log_retention_hrs))
read -e -p "Enter topic retention size (Mb): " -i "25" kafka_topic_log_retention_size_mb
kafka_topic_log_retention_size_bytes=$((1024*1024*$kafka_topic_log_retention_size_mb))
read -e -p "Enter topic max message size (Kb): " -i "256" kafka_topic_max_message_size_kb
kafka_topic_max_message_size_bytes=$((1024*$kafka_topic_max_message_size_kb))


cmd="$KAFKA_HOME/bin/kafka-topics.sh --create \
--zookeeper $zk_host_port \
--replication-factor $replication_factor \
--partitions $partitions \
--topic $topic \
--config max.message.bytes=$kafka_topic_max_message_size_bytes \
--config retention.bytes=$kafka_topic_log_retention_size_bytes \
--config retention.ms=$kafka_topic_log_retention_ms"

echo "$cmd"
prompt=$BOLD$YELLOW"About to start Create Topics as shown, continue? (y/n): $RESET"
default_value="y"
read -e -p "$(echo -e $prompt)" -i $default_value response
if [ "$response" == 'y' ]; then
  eval "$cmd" &
fi
