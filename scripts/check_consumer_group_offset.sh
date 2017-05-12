#!/bin/sh
cd $(dirname $0)

if [ $# -lt 2 ]; then
  node=`hostname |grep -io node[0-9] |awk '{print tolower($0)}'`
  read -e -p "Enter the consumer group id: " -i "$node-consumer-group-1" consumer_group_id
  read -e -p "Enter the bootstrap server: " -i "localhost:9092" bootstrap_server
else
  consumer_group_id=$1
  bootstrap_server=$2
fi

$KAFKA_HOME/bin/kafka-consumer-groups.sh \
--new-consumer \
--bootstrap-server $bootstrap_server \
--describe --group $consumer_group_id
