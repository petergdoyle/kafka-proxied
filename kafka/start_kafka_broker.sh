#!/bin/bash
cd $(dirname $0)
. ./kafka_common.sh

BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`
BKR_PID_CNT=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'| wc -l`

display_info "$BKR_PID_CNT broker process running."
if [ $BKR_PID_CNT -gt 0 ]; then
  read -e -p "$BKR_PID_CNT broker processes already running. Do you want to continue (y/n)? " -i "y" confirm
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
  display_error "Cannot continue. No template file named $broker_config_template_file exists"
  exit 1
fi

no_instances="1"
if [ $BKR_PID_CNT -gt 0 ]; then
  read -e -p "Enter the number of additional broker instances: " -i "$no_instances" no_instances
else
  read -e -p "Enter the number of broker instances: " -i "$no_instances" no_instances
fi
for i in $(eval echo "{1..$no_instances}"); do
  broker_id=$((i+BKR_PID_CNT))
  read -e -p "Confirm the Broker Id (must be unique INT within the cluster): " -i "$broker_id" broker_id
  broker_runtime_console_log_file="$kafka_runtime_console_logs_dir/$node_name-broker-$broker_id-console.log"
  broker_config_file="$kafka_runtime_config_dir/$node_name-broker-$broker_id.properties"
  cp -vf $broker_config_template_file  $broker_config_file
  configure_broker $broker_id

  cmd="$KAFKA_HOME/bin/kafka-server-start.sh $broker_config_file > $broker_runtime_console_log_file 2>&1"
  display_command "$cmd"
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
      display_info "tailing on broker($broker_id) log file for 5 seconds..."
      timeout 5s tail -f "$broker_runtime_console_log_file"
    fi
  else
    display_error "Somthing went wrong. Kafka Broker ($broker_id) does not appear to be running. Checking the log file..."
    sleep 2
    if [ -f $broker_runtime_console_log_file ]; then
      less -f $broker_runtime_console_log_file
    fi
  fi

done
