#!/bin/sh
cd $(dirname $0)
. ./common.sh
./install_kafka.sh

read -e -p "Enter the zk host/port: " -i "localhost:2181" zk_host_port
read -e -p "Enter the topic name: " -i "hertz-edifact" topic


cmd="$KAFKA_HOME/bin/kafka-topics.sh \
--describe \
--topic $topic \
--zookeeper $zk_host_port"

echo "$cmd"
eval "$cmd"
