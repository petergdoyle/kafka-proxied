#!/bin/sh
cd $(dirname $0)
. ./common.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

if [ $# -lt 2 ]; then
  node=`hostname |grep -io node[0-9] |awk '{print tolower($0)}'`
  read -e -p "Enter the consumer group id: " -i "$host_name-consumer-group-1" consumer_group_id
  read -e -p "Enter the bootstrap server: " -i "localhost:9092" bootstrap_server
else
  consumer_group_id=$1
  bootstrap_server=$2
fi

cmd="$KAFKA_HOME/bin/kafka-consumer-groups.sh \
--new-consumer \
--bootstrap-server $bootstrap_server \
--describe --group $consumer_group_id"

display_command "$cmd"
prompt=$BOLD$YELLOW"About to start List Consumer Groups as shown, continue? (y/n): $RESET"
default_value="y"
read -e -p "$(echo -e $prompt)" -i $default_value response
if [ "$response" == 'y' ]; then
  eval "$cmd" 
fi
