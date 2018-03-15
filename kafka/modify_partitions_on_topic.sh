#!/bin/bash
cd $(dirname $0)
. ./kafka_common.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

zk_host_port='localhost:2181'
read -e -p "Enter the zk host/port: " -i "$zk_host_port" zk_host_port

topic='kafka-simple-topic-1'
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

display_command "$cmd"
prompt=$BOLD$YELLOW"About to start Modify Partions on Topic as shown, continue? (y/n): $RESET"
default_value="y"
read -e -p "$(echo -e $prompt)" -i $default_value response
if [ "$response" == 'y' ]; then
  eval "$cmd"
fi
