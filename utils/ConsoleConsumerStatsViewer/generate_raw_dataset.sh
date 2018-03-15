#!/bin/bash
. ../../common.sh

for var in "$@"
do
    echo "$var"
done

num_messages='1000'
read -e -p "Enter number of messages to generate: " -i "$num_messages" num_messages
message_interval='60'
read -e -p "Enter number of simulated seconds between generated messsage timestamps : " -i "$message_interval" message_interval


topic_name='kafka-simple-topic-1'
read -e -p "Enter the topic name: " -i "$topic_name" topic_name

host_public_ip=`curl ifconfig.co 2>/dev/null`

consumer_group_name="`echo $host_public_ip | tr  "."  "-"`-$host_name-$topic_name-consumer-group"
read -e -p "Enter the consumer group name: " -i "$consumer_group_name" consumer_group_name

timestamp=`date +%s`
message_size_lower_bound='48000'
message_size_upper_bound='64000'
message_rate_lower_bound='3000'
message_rate_upper_bound='5000'
for i in `seq 1 $num_messages`; do
  echo "insert msg,consumer_group=$consumer_group_name,ip=$host_public_ip,topic=$topic_name  value=`shuf -i $message_size_lower_bound-$message_size_upper_bound -n 1` `shuf -i $message_rate_lower_bound-$message_rate_upper_bound -n 1`"
  ((timestamp+=$message_interval))
done
