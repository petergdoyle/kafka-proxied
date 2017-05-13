#!/bin/sh
cd $(dirname $0)
./install_kafka.sh

zk_host_port='localhost:2181'
read -e -p "Enter the zk host/port: " -i "$zk_host_port" zk_host_port

topic='hertz-edifact'
read -e -p "Enter the topic name: " -i "$topic" topic

partitions='1'
read -e -p "Enter the number of partitions: " -i "$partitions" partitions

replication_factor='1'
read -e -p "Enter the replication factor: " -i "$replication_factor" replication_factor

cmd="$KAFKA_HOME/bin/kafka-topics.sh --create \
--zookeeper $zk_host_port \
--replication-factor $replication_factor \
--partitions $partitions \
--topic $topic"

echo "$cmd"
eval "$cmd"
