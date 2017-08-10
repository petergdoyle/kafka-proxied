#!/bin/sh
cd $(dirname $0)
. ./build_kafka_configuration.sh

BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`
BKR_PID_CNT=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'| wc -l`

if [ $BKR_PID_CNT -gt 0 ]; then
  echo -e -p "$BKR_PID_CNT broker processes already running. Do you want to continue (y/n)? " -i "y" confirm
  if [ "$confirm" != "y" ]; then
    exit 1
  fi
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
read -e -p "Enter the number of broker instances: " -i "$no_instances" no_instances
for i in $(eval echo "{1..$no_instances}"); do
  broker_id=$i
  read -e -p "Confirm the Broker Id (must be unique INT within the cluster): " -i "$broker_id" broker_id
  broker_config_file="$kafka_runtime_config_dir/$node_name-broker-$broker_id-config.properties"
  broker_runtime_console_log_file="$kafka_base_location/logs/$node_name-broker-$broker_id-console.log"

# start==(( BKR_PID_CNT + 1 ))
# end=(( start + 1 ))
# read -e -p "Enter the number of broker instances: " -i "$end" end
# for i in $(eval echo "{$start..$end}"); do

  broker_config_file="$kafka_runtime_config_dir/$node_name-broker-$i.properties"
  broker_runtime_console_log_file="$kafka_base_location/logs/$node_name-broker-$i-console.log"
  cp -vf $broker_config_template_file  $broker_config_file
  configure_broker "$broker_id"

  cmd="$KAFKA_HOME/bin/kafka-server-start.sh $broker_config_file > $broker_runtime_console_log_file 2>&1"
  echo "$cmd"
  prompt=$BOLD$YELLOW"About to start Kafka Broker, continue? (y/n): $RESET"
  default_value="y"
  read -e -p "$(echo -e $prompt)" -i $default_value response
  if [ "$response" != 'y' ]; then
    exit 0
  fi

  eval "$cmd" &
  sleep 2
  PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`
  if [[ ! -z $PIDS ]]; then
    prompt="Tail on log file ($broker_runtime_console_log_file)? (y/n): "
    default_value="y"
    read -e -p "$prompt" -i $default_value response
    if [ "$response" == 'y' ]; then
      timeout 5s tail -f "$broker_runtime_console_log_file"
    fi
  else
    display_error "broker does not appear to be running"
  fi

done
