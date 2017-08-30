#!/bin/sh
cd $(dirname $0)
. ./common.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

topic='kafka-simple-topic-1'
read -e -p "Enter the topic name: " -i "$topic" topic

from_beggining_response='y'
read -e -p "Read topic from beginning (all messages retained) (y/n): " -i "$from_beggining_response" from_beggining_response
if [ "$from_beggining_response" == "y" ]; then
  from_beggining='--from-beginning'
  delete_consumer_offsets='--delete-consumer-offsets'
else
  from_beggining=''
  delete_consumer_offsets=''
fi

new_consumer='y'
read -e -p "Use new kafka consumer: " -i "$new_consumer" new_consumer
if [ "$new_consumer" == "y" ]; then
  bootstrap_server='localhost:9091'
  read -e -p "Enter the broker host:port : " -i "$bootstrap_server" bootstrap_server
  connect_uri="--new-consumer --bootstrap-server $bootstrap_server"
else
  new_consumer_param='--new-consumer '
  zk_host_port='localhost:2181'
  read -e -p "Enter the zookeeper host:port : " -i "$bootstrap_server" bootstrap_server
  connect_uri="--zookeeper $bootstrap_server"
fi

cmd="$KAFKA_HOME/bin/kafka-console-consumer.sh \
$connect_uri \
--topic $topic \
$from_beggining \
$delete_consumer_offsets"

display_command "$cmd"
eval "$cmd"
