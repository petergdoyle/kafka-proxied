#!/bin/sh
cd $(dirname $0)
. ./build_kafka_configuration.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

create_broker_config

if [ ! -d $kafka_runtime_console_logs_dir ]; then
  mkdir -pv $kafka_runtime_console_logs_dir
fi
cmd="$KAFKA_HOME/bin/kafka-server-start.sh $broker_config_file > $broker_runtime_console_log_file 2>&1"
confirm_execute "$cmd"
sleep 2
PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}'`
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
