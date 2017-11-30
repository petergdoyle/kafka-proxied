#!/bin/sh

        # String bootstrapServers = args[0];
        # String consumerGroup = args[1];
        # String consumerId = args[2];
        # List<String> topics = Arrays.asList(args[3].split(","));
        # long sleep = Long.parseLong(args[4]);

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

cmd="java -jar target/ConsoleConsumerStats-1.0-SNAPSHOT.jar $bootstrap_server $consumer_group_id $consumer_id $sleep"
