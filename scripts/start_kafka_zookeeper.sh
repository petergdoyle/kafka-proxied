#!/bin/sh
cd $(dirname $0)
. ./common.sh
. ./build_kafka_configuration.sh

create_zookeeper_config

cmd="$KAFKA_HOME/bin/zookeeper-server-start.sh $zookeeper_config_file> $zookeeper_runtime_console_log_file 2>&1"
echo "$cmd"
eval "$cmd" &
echo "Output will be redirected to $zookeeper_runtime_console_log_file"
sleep 1
ps ax | grep java | grep -i QuorumPeerMain | grep -v grep
sleep 1
tail -f "$zookeeper_runtime_console_log_file"
