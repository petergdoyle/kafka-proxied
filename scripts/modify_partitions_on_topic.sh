#!/bin/sh
cd $(dirname $0)
./install_kafka.sh


zk_host_port='localhost:2181'
read -e -p "Enter the zk host/port: " -i "$zk_host_port" zk_host_port

topic='hertz-edifact'
read -e -p "Enter the topic name: " -i "$topic" topic
partitions=`$KAFKA_HOME/bin/kafka-topics.sh --describe --zookeeper $zk_host_port --topic $topic |grep 'PartitionCount:' | awk '{print $2}'| grep -Eo '[0-9]'`
if ! [[ $partitions =~ '^[0-9]+$' ]]; then #check for a numeric response
  echo "Cannot determine partitions for topic $topic"
  exit 1
fi

#increment
partitions_new=$((partitions+1))
read -e -p "There are $partitions on this topic \'$topic\'. Enter the new number of partions: " -i "$partitions_new" partitions_new

$KAFKA_HOME/bin/kafka-topics.sh \
--alter \
--zookeeper $zk_host_port \
--topic $topic \
--partitions $partitions
