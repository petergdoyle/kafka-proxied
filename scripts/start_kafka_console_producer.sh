#!/bin/sh
cd $(dirname $0)

if [ -z $KAFKA_HOME ]; then
  kafka_home="$PWD/local/default"
  read -e -p "Enter path for Kafka home directory: " -i "$kafka_home" kafka_home
fi

bootstrap_server='localhost:9092'
read -e -p "Enter a kafka broker server: " -i "$bootstrap_server" bootstrap_server

topic='hertz-edifact'
read -e -p "Enter the topic name: " -i "$topic" topic

$KAFKA_HOME/bin/kafka-console-producer.sh --broker-list $bootstrap_server --topic $topic
