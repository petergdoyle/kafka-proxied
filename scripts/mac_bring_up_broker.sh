#!/bin/sh

kafka_base_dir="/Users/peter/vagrant/kafka-proxied/local/kafka"
kafka_logs_dir="$kafka_base_dir/logs"
kafka_configs_dir="$kafka_base_dir/config"
kafka_home="$kafka_base_dir/default"

export KAFKA_HOME="$kafka_home"

if [ ! -d $kafka_logs_dir ]; then
  mkdir -pv $kafka_logs_dir
fi

if [ ! -d $kafka_configs_dir ]; then
  mkdir -pv $kafka_configs_dir
fi

node_name="Peters-iMac"
broker_id="3"
broker_instance="1"
broker_config_file="$kafka_configs_dir/$node_name-broker-$broker_instance-config.properties"
broker_runtime_console_log_file="$kafka_logs_dir/$node_name-broker-$broker_instance-console.log"
if [ ! -f $broker_config_file ]; then
  echo "Cannot continue without a config file. Need a config file to run the broker. Should be located $broker_config_file"
  exit 1
fi

cmd="$KAFKA_HOME/bin/kafka-server-start.sh $broker_config_file > $broker_runtime_console_log_file"

echo $cmd
sleep 2
eval "$cmd" &

sleep 2


BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`

if [[ ! -z $BKR_PIDS ]]; then
  echo -e "Kafka Broker process(es) running: $BKR_PIDS"
  sleep 1
  timeout 5s tail -f $broker_runtime_console_log_file
else
  echo -e "Kafka Broker process(es) running: No Kafka Broker processes running"
  sleep 1
  tail $broker_runtime_console_log_file
fi
