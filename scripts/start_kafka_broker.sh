#!/bin/sh
cd $(dirname $0)
. ./build_kafka_configuration.sh

BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`

if [ ! -z $BKR_PIDS ]; then\
  display_error "broker is already running ! stop the broker first !"
  exit 1
fi

create_broker_config

cmd="$KAFKA_HOME/bin/kafka-server-start.sh $broker_config_file > $broker_runtime_console_log_file 2>&1"
echo "$cmd"
prompt=$BOLD$YELLOW"About to start Kafka Broker, continue? (y/n): $RESET"
default_value="y"
read -e -p "$(echo -e $prompt)" -i $default_value response
if [ "$response" == 'y' ]; then
  eval "$cmd" &
fi

sleep 2
PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`
if [ ! -z $PIDS ]; then
  prompt="Tail on log file? (y/n): "
  default_value="y"
  read -e -p "$prompt" -i $default_value response
  if [ "$response" == 'y' ]; then
    tail -f "$broker_runtime_console_log_file"
  fi
else
  display_error "broker does not appear to be running"
fi
