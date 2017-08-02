#!/bin/sh

RESET="\033[0m"
BOLD="\033[1m"
YELLOW="\033[38;5;11m"
GREEN="\033[32m"
BLUE="\033[34m"
RED="\033[91m"


host_name=`hostname| cut -d"." -f1`
node_name=`echo $host_name |grep -Eo "broker[0-9]|zookeeper[0-9]" |awk '{print tolower($0)}'| grep '.*'`
if [ "$node_name" == "" ]; then
  node_name=$host_name
fi

parent_dir="$(dirname "$(pwd)")"

kafka_version="0.10.1.1"
scala_version="2.11"

if [[ $EUID -eq 0 ]]; then #check if run as root to determine where to install kafka
  kafka_base_location="/usr/kafka"
else
  kafka_base_location=$parent_dir/local/kafka
fi
kafka_installation_dir="$kafka_base_location/kafka_$scala_version-$kafka_version"

kafka_runtime_console_logs_dir="$kafka_base_location/logs"
broker_runtime_console_log_file="$kafka_base_location/logs/$node_name-broker.log"
zookeeper_runtime_console_log_file="$kafka_base_location/logs/$node_name-zookeeper.log"
mm_runtime_console_log_file="$kafka_base_location/logs/$node_name-mm.log"

kafka_templates_config_dir="$PWD/config/$kafka_version"
broker_config_template_file="$kafka_templates_config_dir/broker-template.properties"
zookeeper_config_template_file="$kafka_templates_config_dir/zookeeper-template.properties"
mm_producer_config_template_file="$kafka_templates_config_dir/mm_producer-template.properties"
mm_consumer_config_template_file="$kafka_templates_config_dir/mm_consumer-template.properties"

kafka_runtime_config_dir="$kafka_base_location/config"
broker_config_file="$kafka_runtime_config_dir/$node_name-broker.properties"
zookeeper_config_file="$kafka_runtime_config_dir/$node_name-zookeeper.properties"
mm_producer_config_file="$kafka_runtime_config_dir/$node_name-mm_producer.properties"
mm_consumer_config_file="$kafka_runtime_config_dir/$node_name-mm_consumer.properties"


function confirm_execute() {
  local cmd="$1"
  local prompt="about to run command, confirm (y/n): "
  read -e -p "$(echo -e $BOLD$YELLOW$prompt $cmd $GREEN)" -i "y" response
  echo -e $RESET
  if [ "$run_it" == "y" ]; then
    eval "$cmd"
  fi
}

function prompt() {
  local prompt=$1
  local default_value=$2
  # local d_prompt="$(echo -e $BOLD$YELLOW$prompt)"
  # local d_default_value="$(echo -e $GREEN$default_value)"
  local value=""

  read -e -p "$prompt" -i "$d_default_value" value
  echo -e "$RESET"
  echo $value
}

function display_info() {
  local msg="$1"
  echo -e "[info] "$BOLD$BLUE$msg$RESET
}

function check_kafka_installed() {
  if [[ $EUID -eq 0 ]]; then #check if run as root to determine where to install kafka
    kafka_base_location="/usr/kafka"
  else
    kafka_base_location=$parent_dir/local/kafka
  fi
  if [ "$(ls -A $kafka_base_location)" ]; then
    echo "true"
    #  echo "Take action $DIR is not Empty"
  else
    # echo "$DIR is Empty"
    echo "false"
  fi
}

function check_env() {

  if [ -z ${KAFKA_HOME+x} ]; then
    prompt="Kafka does not appear to be installed. Install Kafka locally? "
    default_value="y"
    read -e -p "$prompt" -i $default_value response
    if [ "$response" != 'y' ]; then
     echo "Cannot continue"
     exit 1
    fi
  fi

}


display_info " "
display_info "host_name: $host_name"
display_info "cluster node_name: $node_name"
display_info "host_name: $host_name"
display_info " "

display_info "kafka version: $kafka_version"
display_info "kafka installation location: $kafka_installation_dir"
display_info "kafka configuration templates location: $kafka_templates_config_dir"
display_info "kafka runtime configuration location: $kafka_runtime_config_dir"
display_info "kafka runtime logs directory: $kafka_runtime_console_logs_dir"
display_info " "

display_info "kafka broker config file: $broker_config_file"
display_info "kafka zookeeper config file: $zookeeper_config_file"
display_info "kafka mirror-maker producer config file: $mm_producer_config_file"
display_info "kafka mirror-maker consumer config file: $mm_consumer_config_file"
display_info " "

display_info "kafka broker config template file: $broker_config_template_file"
display_info "kafka zookeeper config template file: $zookeeper_config_template_file"
display_info "kafka mirror-maker producer config template file: $mm_producer_config_template_file"
display_info "kafka mirror-maker consumer config template file: $mm_consumer_config_template_file"
display_info " "
