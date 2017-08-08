#!/bin/sh
cd $(dirname $0)
. ./common.sh

ZK_PIDS=`ps ax | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`

if [ -z $ZK_PIDS ]; then\
  display_error "zookeeper is not running ! start the cluster first !"
  exit 1
fi

number_of_zookeepers=`find $kafka_runtime_console_logs_dir -type f -name '*broker*' |wc -l`
selected_zookeper='1'
if [ $number_of_zookeepers -gt 1 ]; then
  read -e -p "A total of $number_of_zookeepers broker log file(s) found. Which broker (number)?: " -i "$selected_zookeper" selected_zookeper
fi
zookeeper_runtime_console_log_file="$kafka_base_location/logs/$node_name-zookeeper-$selected_zookeper-console.log"

tail -f "$zookeeper_runtime_console_log_file"
