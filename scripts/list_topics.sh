#!/bin/sh
cd $(dirname $0)
. ./common.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

read -e -p "Enter the zk host/port: " -i "localhost:2181" zk_host_port

cmd="$KAFKA_HOME/bin/kafka-topics.sh --list --zookeeper $zk_host_port"

confirm_execute "$cmd"
