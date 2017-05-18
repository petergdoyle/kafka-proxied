#!/bin/sh
cd $(dirname $0)
. ./common.sh
. ./install_kafka.sh

if [ -z $KAFKA_HOME ]; then
  kafka_home="$PWD/local/default"
  read -e -p "Enter path for Kafka home directory: " -i "$kafka_home" kafka_home
fi

bootstrap_server='localhost:9092'
read -e -p "Enter the bootstrap server: " -i "$bootstrap_server" bootstrap_server

topic='hertz-edifact'
read -e -p "Enter the topic name: " -i "$topic" topic

cmd="$KAFKA_HOME/bin/kafka-console-consumer.sh \
--new-consumer \
--bootstrap-server $bootstrap_server \
--topic $topic \
--from-beginning"

confirm_execute "$cmd"
