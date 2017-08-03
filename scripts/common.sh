#!/bin/sh

# Black        0;30     Dark Gray     1;30
# Red          0;31     Light Red     1;31
# Green        0;32     Light Green   1;32
# Brown/Orange 0;33     Yellow        1;33
# Blue         0;34     Light Blue    1;34
# Purple       0;35     Light Purple  1;35
# Cyan         0;36     Light Cyan    1;36
# Light Gray   0;37     White         1;37

RESET="\033[0m"
BOLD="\033[1m"
YELLOW="\033[38;5;11m"
GREEN="\033[1,32m"
BLUE="\033[1;36m"
RED="\033[1;31m"
ORANGE="\033[0,33m"
# ORANGE=$'\e[33;40m'


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
broker_runtime_console_log_file="$kafka_base_location/logs/$node_name-broker-console.log"
zookeeper_runtime_console_log_file="$kafka_base_location/logs/$node_name-zookeeper-console.log"
mm_runtime_console_log_file="$kafka_base_location/logs/$node_name-mirror-maker-console.log"

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

zookeeper_process_running_cmd="ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'"

kafka_broker_logs_dir='/tmp/kafka-logs'
zookeeper_logs_dir='/tmp/zookeeper'

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
  echo -e $BLUE"[info] $msg"$RESET
}

function display_error() {
  local msg="$1"
  echo -e $BOLD$RED"[error] $msg"$RESET
}

function display_warn() {
  local msg="$1"
  echo -e $BOLD$ORANGE"[warn] $msg"$RESET
}

function check_kafka_installed() {
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

# ZK_PIDS=`ps ax | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`
# BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`
# MM_PIDS=`ps ax | grep -i MirrorMaker | grep -v grep | awk '{print $1}'`

function check_zookeper_status() {

  ZK_PIDS=`ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`

  [[ ! -z $ZK_PIDS ]] \
    && display_info "Zookeeper process(es) running: $ZK_PIDS" \
    || display_warn "Zookeeper process(es) running: No Zookeeper processes running"

}

function check_broker_status() {

  BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`

  [[ ! -z $BKR_PIDS ]] \
    && display_info "Kafka Broker process(es) running: $BKR_PIDS" \
    || display_warn "Kafka Broker process(es) running: No Kafka Broker processes running"

}

function check_mirror_maker_status() {

  MM_PIDS=`ps ax | grep -i MirrorMaker | grep -v grep | awk '{print $1}'`

  [[ ! -z $MM_PIDS ]] \
    && display_info "Mirror-Maker process(es) running: $MM_PIDS" \
    || display_warn "Mirror-Maker process(es) running: No Mirror-Maker processes running"

}


function show_cluster_state() {

  display_info "Host Details:"
  display_info "full host name: `hostname`"
  display_info "host name: $host_name"
  display_info "kafka cluster node_name: $node_name"
  display_info "network interfaces: `ifconfig |grep 'inet '| awk '{print $2}'| tr '\n' '  '|sed '$s/.$//'`"
  display_info " "

  display_info "Kafka Details:"
  display_info "kafka version: $kafka_version"
  [[ -d $kafka_installation_dir ]] \
  && display_info "kafka installation location: $kafka_installation_dir" \
  || display_warn "kafka installation location: Not installed"
  [[ ! -z $KAFKA_HOME ]] \
  && display_info "KAFKA_HOME: $KAFKA_HOME" \
  || display_warn "KAFKA_HOME: Not set"
  display_info " "

  display_info "Kafka Configuration:"
  display_info "kafka runtime configuration location: $kafka_runtime_config_dir"

  [[ -f $broker_config_file ]] \
  && display_info "kafka runtime configuration location: $broker_config_file" \
  || display_warn "kafka runtime configuration location: $broker_config_file *Does not exist"

  [[ -f $zookeeper_config_file ]] \
  && display_info "kafka zookeeper config file: $zookeeper_config_file" \
  || display_warn "kafka zookeeper config file: $zookeeper_config_file *Does not exist"

  [[ -f $mm_producer_config_file ]] \
  && display_info "kafka mirror-maker producer config file: $mm_producer_config_file" \
  || display_warn "kafka mirror-maker producer config file: $mm_producer_config_file *Does not exist"

  [[ -f $mm_consumer_config_file ]] \
  && display_info "kafka mirror-maker consumer config file: $mm_consumer_config_file" \
  || display_warn "kafka mirror-maker consumer config file: $mm_consumer_config_file *Does not exist"

  display_info " "

  display_info "Kafka Configuration Templates:"
  display_info "kafka configuration templates location: $kafka_templates_config_dir"
  display_info "kafka broker config template file: $broker_config_template_file"
  display_info "kafka zookeeper config template file: $zookeeper_config_template_file"
  display_info "kafka mirror-maker producer config template file: $mm_producer_config_template_file"
  display_info "kafka mirror-maker consumer config template file: $mm_consumer_config_template_file"
  display_info " "

  display_info "Kafka Logs:"
  [[ -f $kafka_broker_logs_dir ]] \
  && display_info "kafka cluster broker logs location: $kafka_broker_logs_dir" \
  || display_warn "kafka cluster broker logs location: $kafka_broker_logs_dir *Does not exist"

  [[ -f $zookeeper_logs_dir ]] \
  && display_info "kafka cluster zookeeper logs location: $zookeeper_logs_dir" \
  || display_warn "kafka cluster zookeeper logs location: $zookeeper_logs_dir *Does not exist"

  [[ -f $kafka_runtime_console_logs_dir ]] \
  && display_info "kafka runtime logs directory: $kafka_runtime_console_logs_dir" \
  || display_warn "kafka runtime logs directory: $kafka_runtime_console_logs_dir *Does not exist"

  [[ -f $broker_runtime_console_log_file ]] \
  && display_info "kafka broker runtime console log: $broker_runtime_console_log_file" \
  || display_warn "kafka broker runtime console log: $broker_runtime_console_log_file *Does not exist"

  [[ -f $zookeeper_runtime_console_log_file ]] \
  && display_info "kafka zookeeper runtime console log: $zookeeper_runtime_console_log_file" \
  || display_warn "kafka zookeeper runtime console log: $zookeeper_runtime_console_log_file *Does not exist"

  [[ -f $mm_runtime_console_log_file ]] \
  && display_info "kafka mirror-maker runtime console log: $mm_runtime_console_log_file" \
  || display_warn "kafka mirror-maker runtime console log: $mm_runtime_console_log_file *Does not exist"

  display_info " "

  display_info "Kafka Cluster Status:"
  check_zookeper_status
  check_broker_status
  check_mirror_maker_status

}
