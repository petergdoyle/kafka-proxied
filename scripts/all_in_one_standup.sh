#!/bin/sh
cd $(dirname $0)

./start_kafka_zookeeper.sh
./start_kafka_broker.sh 
