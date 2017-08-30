#!/bin/sh
cd $(dirname $0)

./kill_kafka_broker.sh
./kill_kafka_zookeeper.sh
./kill_kafka_mirror_maker.sh
./cleanup_kafka_runtime.sh
