#!/bin/sh
cd $(dirname $0)
. ./common.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

bootstrap_server='localhost:9092'
read -e -p "Enter a kafka broker server: " -i "$bootstrap_server" bootstrap_server

topic='hertz-edifact'
read -e -p "Enter the topic name: " -i "$topic" topic

cmd="$KAFKA_HOME/bin/kafka-console-producer.sh --broker-list $bootstrap_server --topic $topic"

echo "$cmd"
eval "$cmd"
