#!/bin/bash
cd $(dirname $0)

./start_kafka_zookeeper.sh
./start_kafka_broker.sh
./create_topic.sh
./tail_kafka_controller_log.sh
sleep 1
./check_status.sh 
