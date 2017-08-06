#!/bin/sh
cd $(dirname $0)
. ./common.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

read -e -p "Enter the zk host/port: " -i "localhost:2181" zk_host_port
read -e -p "Enter the topic name: " -i "hertz-edifact" topic


cmd="$KAFKA_HOME/bin/kafka-topics.sh \
--describe \
--topic $topic \
--zookeeper $zk_host_port"

echo "$cmd"
prompt=$BOLD$YELLOW"About to start List Partitions on Topic as shown, continue? (y/n): $RESET"
default_value="y"
read -e -p "$(echo -e $prompt)" -i $default_value response
if [ "$response" == 'y' ]; then
  eval "$cmd" 
fi
