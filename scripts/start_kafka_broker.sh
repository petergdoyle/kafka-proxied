#!/bin/sh
cd $(dirname $0)
. ./common.sh
. ./build_kafka_configuration.sh

create_broker_config

mkdir -p $PWD/../local/logs/$node_name/
broker_log_file="$PWD/../local/logs/$node_name/kafka_broker_console.log"
cmd="$KAFKA_HOME/bin/kafka-server-start.sh $broker_config_file > $broker_log_file 2>&1"
echo "$cmd"
eval "$cmd" &
echo "Output will be redirected to $broker_log_file"
sleep 1
ps aux |grep java |grep --color -v grep
sleep 1
tail -f "$broker_log_file"
