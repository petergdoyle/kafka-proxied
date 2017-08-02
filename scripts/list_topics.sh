#!/bin/sh
cd $(dirname $0)
. ./common.sh

read -e -p "Enter the zk host/port: " -i "localhost:2181" zk_host_port

cmd="$KAFKA_HOME/bin/kafka-topics.sh --list --zookeeper $zk_host_port"

confirm_execute "$cmd"
