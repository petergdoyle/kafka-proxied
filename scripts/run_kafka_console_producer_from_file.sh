#!/bin/sh


if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

bootstrap_server='localhost:9092'
read -e -p "Enter the bootstrap server: " -i "$bootstrap_server" bootstrap_server

topic_name='localhost:9092'
read -e -p "Enter the topic name: " -i "$topic_name" topic_name

id_range_lo='0'
read -e -p "Enter message id range lo: " -i "$id_range_lo" id_range_lo
id_range_hi='99'
read -e -p "Enter message id range hi: " -i "$id_range_hi" id_range_hi


# for i in {1000...2999}; do echo `hostname`-auto-generated-message-$i; done > messages
for i in $(eval echo "{$id_range_lo..$id_range_hi}"); do echo `hostname`-auto-generated-message-$i; done > messages

$KAFKA_HOME/bin/kafka-console-producer.sh --broker-list $bootstrap_server --topic $topic_name< messages
