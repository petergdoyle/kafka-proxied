l#!/bin/sh
cd $(dirname $0)
. ./common.sh

BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`

if [[ -z $BKR_PIDS ]]; then\
  display_error "broker is not running ! stop the broker first !"
  exit 1
fi


number_of_brokers=`find $kafka_runtime_console_logs_dir -type f -name '*broker*' |wc -l`
selected_broker='1'
read -e -p "A total of $number_of_brokers found. Which broker (number)?: " -i "$selected_broker" selected_broker
broker_runtime_console_log_file="$kafka_base_location/logs/$node_name-broker-$selected_broker-console.log"

tail -f "$broker_runtime_console_log_file"
