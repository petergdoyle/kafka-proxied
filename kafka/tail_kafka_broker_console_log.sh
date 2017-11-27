#!/bin/sh
cd $(dirname $0)
. ./common.sh

BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`

if [[ -z $BKR_PIDS ]]; then
  display_info "Warning. No Kafka Broker is running"
fi

number_of_brokers=`find $kafka_runtime_console_logs_dir -type f -name '*broker*' |wc -l`
selected_broker='1'
if [ $number_of_brokers -gt 1 ]; then
  read -e -p "A total of $number_of_brokers broker log file(s) found. Which broker (number)?: " -i "$selected_broker" selected_broker
fi
broker_runtime_console_log_file="$kafka_base_location/logs/$node_name-broker-$selected_broker-console.log"

if [ ! -f $broker_runtime_console_log_file ]; then
  display_error "the file $broker_runtime_console_log_file does not exist."
  exit 1
fi
tail -f "$broker_runtime_console_log_file"
