#!/bin/bash


broker_host_port='localhost:9091'
read -e -p "Enter the broker host/port: " -i "$broker_host_port" broker_host_port

topic='kafka-simple-topic-1'
read -e -p "Enter the topic name: " -i "$topic" topic


mvn -f $PWD/springboot-pom.xml clean install &&
java -DKAFKA_TOPIC=$topic -DKAFKA_BOOTSTRAP_SERVERS=$broker_host_port -jar target/HttpKafkaAdapter-1.0-SNAPSHOT.jar
