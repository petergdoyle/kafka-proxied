#!/bin/sh
cd $(dirname $0)
. ./build_kafka_configuration.sh

BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`

if [ ! -z $BKR_PIDS ]; then\
  display_error "broker is already running ! stop the broker first !"
  exit 1
fi

if [ ! -d $kafka_runtime_config_dir ]; then
  mkdir -pv $kafka_runtime_config_dir
fi

if [ ! -d $kafka_runtime_console_logs_dir ]; then
  mkdir -pv $kafka_runtime_console_logs_dir
fi

if [ ! -f $broker_config_template_file ]; then
  "cannot continue. no template file named $broker_config_template_file exists"
  exit 1
fi

no_instances="1"
read -e -p "Enter the number of zookeeper instances: " -i "$no_instances" no_instances
for i in $(eval echo "{1..$no_instances}"); do

  broker_config_file="$kafka_runtime_config_dir/$node_name-broker-$i.properties"
  broker_runtime_console_log_file="$kafka_base_location/logs/$node_name-broker-$i-console.log"
  cp -vf $broker_config_template_file  $broker_config_file
  configure_broker "$i"

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
  if [[ ! -z $PIDS ]]; then
    prompt="Tail on log file? (y/n): "
    default_value="y"
    read -e -p "$prompt" -i $default_value response
    if [ "$response" == 'y' ]; then
      timeout 5s tail "$broker_runtime_console_log_file"
    fi
  else
    display_error "broker does not appear to be running"
  fi

done
