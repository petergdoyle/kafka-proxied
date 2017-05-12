#!/bin/sh
cd $(dirname $0)

read -e -p "Enter the bootstrap server: " -i "localhost:9092" bootstrap_server

$KAFKA_HOME/bin/kafka-run-class.sh kafka.admin.ConsumerGroupCommand \
--new-consumer \
--list \
--bootstrap-server $bootstrap_server
