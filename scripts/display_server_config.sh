#!/bin/sh
cd $(dirname $0)
. ./common.sh

number_of_brokers=`find $kafka_runtime_config_dir -type f -name '*broker*' |wc -l`
selected_broker='1'
if [ $number_of_brokers -gt 1 ]; then
  read -e -p "A total of $number_of_brokers broker config file(s) found. Which broker (number)?: " -i "$selected_broker" selected_broker
fi
broker_config_file="$kafka_runtime_config_dir/$node_name-broker-$selected_broker.properties"

grep -v "^#" $broker_config_file|awk 'NF'
