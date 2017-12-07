#!/bin/sh

BOLD="\033[1m"
YELLOW="\033[38;5;11m"
GREEN="\033[1,32m"
BLUE="\033[1;36m"
VIOLET="\033[1;34m"
RESET="\033[0m"

bootstrap_server="localhost:9091"
read -e -p "Enter Kafka bootstrap server for kafka conxumer to take data: " -i "$bootstrap_server" bootstrap_server

host_name=`hostname| cut -d"." -f1`
node_name=`echo $host_name |grep -Eo "broker[0-9]|zookeeper[0-9]" |awk '{print tolower($0)}'| grep '.*'`
if [ "$node_name" == "" ]; then
  node_name=$host_name
fi
read -e -p "Enter the consumer group id: " -i "$node_name-consumer-group" consumer_group_id

consumer_id="$consumer_group_id-1"
read -e -p "Enter the consumer id: " -i "$consumer_id" consumer_id

topic='kafka-simple-topic-1'
read -e -p "Enter the topic name: " -i "$topic" topic

sleep="0"
read -e -p "Enter the sleep time: " -i "$sleep" sleep

threads="1"
read -e -p "Enter the number of Consumer Threads: " -i "$threads" threads

ssl_true_response='n'
read -e -p "Do you need to configure SSL for this Kafka bootstrap server (y/n): " -i "$ssl_true_response" ssl_true_response
if [ "$ssl_true_response" == "y" ]; then
  ssl_true='true'
  keystore_file=$PWD my.prod.truststore.jks
  while true; do
    read -e -p "Specify the jks keystor file: " -i "$keystore_file" keystore_file
    if [ -f $keystore_file ]; then
      break
    else
      display_error "Specified file $keystore_file does not exist"
    fi
  done

  keystore_password="majiic"
  read -e -p "Specify the truststore password: " -i "$keystore_password" keystore_password
else
  ssl_true='false'
fi

verbose_response="n"
read -e -p "Show message details: " -i "$verbose_response" verbose_response
if [ "$verbose_response" == "y" ]; then
  verbose='true'
else
  verbose="false"
fi

class_name="com.cleverfishsoftware.kafka.utils.ConsumerCounterRunner"
cmd="java -cp .:target/ConsoleConsumerStats-1.0-SNAPSHOT.jar $class_name $bootstrap_server $consumer_group_id $consumer_id $topic $sleep $threads $verbose $ssl_true $keystore_file $keystore_password"
display_command "$cmd"
echo -e $BOLD$VIOLET"[info] $cmd"$RESET

prompt=$BOLD$YELLOW"About to run command, continue? (y/n): $RESET"
default_value="y"
read -e -p "$(echo -e $prompt)" -i $default_value response
if [ "$response" != 'y' ]; then
  exit 0
fi

eval "$cmd"
