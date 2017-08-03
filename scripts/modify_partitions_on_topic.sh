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
partitions=`$KAFKA_HOME/bin/kafka-topics.sh --describe --zookeeper $zk_host_port --topic $topic |grep 'PartitionCount:' | awk '{print $2}'| grep -Eo '[0-9]'`
if [ "$partitions" -ne "$partitions" ]; then #check for a numeric response
  echo "Cannot determine partitions for topic $topic"
fi

#increment
partitions_new=$((partitions+1))
read -e -p "There are $partitions partitions on topic '$topic'. Enter the new number of partions: " -i "$partitions_new" partitions_new

cmd="$KAFKA_HOME/bin/kafka-topics.sh \
--alter \
--zookeeper $zk_host_port \
--topic $topic \
--partitions $partitions_new"

confirm_execute "$cmd"
