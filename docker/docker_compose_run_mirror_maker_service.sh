#!/bin/sh

if [ ! -f kafka/config/mm_consumer.properties ]; then
  display_error "No mirror-maker configuration found. Run docker_build_kafka_image first."
  exit 1
fi

topic='kafka-replicated-topic-1'
read -e -p "Enter the topic to mirror: " -i "$topic" topic

host_consumer=`cat kafka/config/mm_consumer.properties |sed -n 's/^bootstrap.servers=//p' |sed 's/:.*$//'`
host_consumer_ip=`ping -c 1 $host_consumer| sed -n 2p| sed 's/.*(\(.*\))/\1/' |sed 's/:.*//'`
read -e -p "Enter ip number for consumer $host_consumer: " -i "$host_consumer_ip" host_consumer_ip
host_producer=`cat kafka/config/mm_producer.properties |sed -n 's/^bootstrap.servers=//p' |sed 's/:.*$//'`
host_producer_ip=`ping -c 1 $host_producer| sed -n 2p| sed 's/.*(\(.*\))/\1/' |sed 's/:.*//'`
read -e -p "Enter ip number for producer $host_producer: " -i "$host_producer_ip" host_producer_ip

cp -vf docker-compose-mirror-maker-template.yml docker-compose.yml
token='${CONSUMER_BROKER_ADDRESS}'
sed -i "s/$token/$host_consumer:$host_consumer_ip/g" docker-compose.yml
token='${PRODUCER_BROKER_ADDRESS}'
sed -i "s/$token/$host_producer:$host_producer_ip/g" docker-compose.yml
token='${TOPIC_WHITELIST}'
sed -i "s/$token/$topic/g" docker-compose.yml

scale='3'
service="kafka-mirror-maker-service"
read -e -p "Enter the scale factor for $service: " -i "$scale" scale

detached=''
confirm='y'
read -e -p "Run in background (y/n): " -i "$confirm" confirm
if [ "$confirm" == "y" ]; then
  detached='-d'
fi

cmd="docker-compose up $detached --scale kafka-mirror-maker-service=$scale"
echo "$cmd"
eval "$cmd"
