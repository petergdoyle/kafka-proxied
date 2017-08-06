#!/bin/sh
cd $(dirname $0)
. ./common.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

bootstrap_server='localhost:9092'
read -e -p "Enter the bootstrap server: " -i "$bootstrap_server" bootstrap_server

cmd="$KAFKA_HOME/bin/kafka-run-class.sh kafka.admin.ConsumerGroupCommand \
--new-consumer \
--list \
--bootstrap-server $bootstrap_server"

echo "$cmd"
prompt=$BOLD$YELLOW"About to start List Active Consumer Groups shown, continue? (y/n): $RESET"
default_value="y"
read -e -p "$(echo -e $prompt)" -i $default_value response
if [ "$response" == 'y' ]; then
  eval "$cmd" 
fi
