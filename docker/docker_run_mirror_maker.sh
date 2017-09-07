#!/bin/sh

topic='kafka-replicated-topic-1'
read -e -p "Enter the topic to mirror: " -i "$topic" topic

cmd="bin/kafka-mirror-maker.sh \
--consumer.config config/mm_consumer.properties \
--producer.config config/mm_producer.properties \
--whitelist=\"$topic\""
cmd_shell="/bin/bash"

host_consumer=`cat kafka/config/mm_consumer.properties |sed -n 's/^bootstrap.servers=//p' |sed 's/:.*$//'`
host_consumer_ip=`ping -c 1 $host_consumer| sed -n 2p| sed 's/.*(\(.*\))/\1/' |sed 's/:.*//'`
read -e -p "Enter ip number for consumer $host_consumer: " -i "$host_consumer_ip" host_consumer_ip
host_producer=`cat kafka/config/mm_producer.properties |sed -n 's/^bootstrap.servers=//p' |sed 's/:.*$//'`
host_producer_ip=`ping -c 1 $host_producer| sed -n 2p| sed 's/.*(\(.*\))/\1/' |sed 's/:.*//'`
read -e -p "Enter ip number for producer $host_producer: " -i "$host_producer_ip" host_producer_ip

docker_cmd="docker run -ti --rm --add-host=$host_consumer:$host_consumer_ip --add-host=$host_producer:$host_producer_ip mycompany/kafka $cmd"

echo "$docker_cmd"

docker run -ti --rm --add-host=$host_consumer:$host_consumer_ip --add-host=$host_producer:$host_producer_ip mycompany/kafka $cmd
