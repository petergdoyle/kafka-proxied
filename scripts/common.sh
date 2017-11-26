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
VIOLET="\033[1;34m"
RED="\033[1;31m"
ORANGE="\033[0,33m"
# ORANGE=$'\e[33;40m'

function display_info() {
  local msg="$1"
  echo -e $BOLD$BLUE"[info] $msg"$RESET
}

function display_error() {
  local msg="$1"
  echo -e $BOLD$RED"[error] $msg"$RESET
}

function display_warn() {
  local msg="$1"
  echo -e $BOLD$ORANGE"[warn] $msg"$RESET
}

function display_H1() {
  local msg="$1"
  echo -e $BOLD$VIOLET"[info] $msg"$RESET
}

function display_break() {
  echo -e ""
}

function display_command() {
  local cmd="$1"
  echo -e $BOLD$VIOLET"[info] $cmd"$RESET
}

validate_url() {
  local url=$1
  if [ -e $url ]; then
    echo "variable url is not set. cannot continue"
    return 1
  fi
  response_code=$(curl --write-out %{http_code} --silent --output /dev/null $url)
  # echo $response_code
  # if [ "$response_code" -eq "000" ]; then
    return $response_code
  # else
  #   return 0
  # fi
}

host_name=`hostname| cut -d"." -f1`
node_name=`echo $host_name |grep -Eo "broker[0-9]|zookeeper[0-9]" |awk '{print tolower($0)}'| grep '.*'`
if [ "$node_name" == "" ]; then
  node_name=$host_name
fi

parent_dir="$(dirname "$(pwd)")"


if [[ $EUID -eq 0 ]]; then #check if run as root to determine where to install kafka
  kafka_base_location="/usr/kafka"
else
  kafka_base_location=$parent_dir/local/kafka
fi
kafka_home="$kafka_base_location/default"

kafka_version=`readlink -f $kafka_home | awk -F- '{print $NF}'`
if [ -z $kafka_version ]; then
  kafka_version=`find config -type d| awk -F'/' '{print $2}'|sed '/^$/d'| head -1` #select the first one found under config
fi
scala_version="2.11"

function set_kafka_variables() {

  kafka_installation_dir="$kafka_base_location/kafka_$scala_version-$kafka_version"

  kafka_runtime_logs_dir="$kafka_base_location/default/logs"
  kafka_controller_log_file="$kafka_runtime_logs_dir/controller.log"

  kafka_runtime_console_logs_dir="$kafka_base_location/logs"
  broker_runtime_console_log_file="$kafka_base_location/logs/$node_name-broker-console.log"
  zookeeper_runtime_console_log_file="$kafka_base_location/logs/$node_name-zookeeper-console.log"
  mm_runtime_console_log_file="$kafka_base_location/logs/$node_name-mirror-maker-console.log"

  kafka_templates_config_dir="$PWD/config/$kafka_version"
  broker_config_template_file="$kafka_templates_config_dir/broker-template.properties"
  zookeeper_config_template_file="$kafka_templates_config_dir/zookeeper-template.properties"
  mm_producer_config_template_file="$kafka_templates_config_dir/mm_producer-template.properties"
  mm_consumer_config_template_file="$kafka_templates_config_dir/mm_consumer-template.properties"
  consumer_ssl_config_template_file="$kafka_templates_config_dir/console-consumer-ssl-template.properties"
  producer_ssl_config_template_file="$kafka_templates_config_dir/console-producer-ssl-template.properties"

  kafka_runtime_config_dir="$kafka_base_location/config"
  broker_config_file="$kafka_runtime_config_dir/$node_name-broker.properties"
  zookeeper_config_file="$kafka_runtime_config_dir/$node_name-zookeeper.properties"
  mm_producer_config_file="$kafka_runtime_config_dir/$node_name-mm_producer.properties"
  mm_consumer_config_file="$kafka_runtime_config_dir/$node_name-mm_consumer.properties"
  consumer_ssl_config_file="$kafka_runtime_config_dir/console-consumer-ssl.properties"
  producer_ssl_config_file="$kafka_runtime_config_dir/console-producer-ssl.properties"

  zookeeper_process_running_cmd="ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'"

  kafka_broker_logs_dir='/tmp/kafka-logs'
  zookeeper_logs_dir='/tmp/zookeeper'
}

set_kafka_variables

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

  ZK_PIDS=`ps ax | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`

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

  display_H1 "Host Details:"$RESET
  display_info "full host name: `hostname`"
  display_info "host name: $host_name"
  display_info "kafka cluster node_name: $node_name"
  display_info "network interfaces: `ifconfig |grep 'inet '| awk '{print $2}'| tr '\n' '  '|sed '$s/.$//'`"
  display_info "cpu info: `grep '^model name' /proc/cpuinfo | awk '!a[$0]++'| sed -e 's/.*: //'` (`grep -c ^processor /proc/cpuinfo`)"
  display_break

  display_H1 "Kafka Details:"$RESET
  display_info "kafka version: $kafka_version"
  [[ -d $kafka_installation_dir ]] \
  && display_info "kafka installation location: $kafka_installation_dir" \
  || display_warn "kafka installation location: Not installed"
  [[ ! -z $KAFKA_HOME ]] \
  && display_info "KAFKA_HOME: $KAFKA_HOME" \
  || display_warn "KAFKA_HOME: Not set ==> Please run install_kafka.sh or source ~/.bash_profile if installed kafka and did not do so."

  if [ -d $kafka_home ]; then #kafka is installed
    if [ "`readlink $kafka_base_location/default`" -ef "$kafka_installation_dir" ]; then
      display_info "The kafka version $kafka_version matches what is linked at $kafka_home "
    else
      display_error "The kafka version $kafka_version does not match with what is linked at `readlink $kafka_home` ==> Please run install_kafka.sh or change the kafka_version in common.sh";
    fi
  fi

  [[ -d $kafka_runtime_logs_dir ]] \
  && display_info "kafka runtime logs dir: $kafka_runtime_logs_dir" \
  || display_warn "kafka runtime logs dir: $kafka_runtime_logs_dir *Has not been created yet!"
  display_break

  display_H1 "Kafka Configuration:"
  display_info "kafka runtime configuration location: $kafka_runtime_config_dir"

  if [ `find $kafka_runtime_config_dir -name '*broker*'| wc -l` -gt 0 ]; then
    for each in `find $kafka_runtime_config_dir -name '*broker*'`; do
      display_info "kafka broker config file found : $each"
    done
  else
    display_warn "No kafka broker config files found. *Has not been created yet!"
  fi

  if [ `find $kafka_runtime_config_dir -name '*zookeeper*'| wc -l` -gt 0 ]; then
    for each in `find $kafka_runtime_config_dir -name '*zookeeper*'`; do
      display_info "kafka zookeeper config file found: $each"
    done
  else
    display_warn "No kafka zookeeper config files found. *Has not been created yet!"
  fi

  [[ -f $mm_producer_config_file ]] \
  && display_info "kafka mirror-maker producer config file: $mm_producer_config_file" \
  || display_warn "kafka mirror-maker producer config file: $mm_producer_config_file *Has not been created yet!"
  [[ -f $mm_consumer_config_file ]] \
  && display_info "kafka mirror-maker consumer config file: $mm_consumer_config_file" \
  || display_warn "kafka mirror-maker consumer config file: $mm_consumer_config_file *Has not been created yet!"
  [[ -f $consumer_ssl_config_file ]] \
  && display_info "kafka mirror-maker consumer config file: $consumer_ssl_config_file" \
  || display_warn "kafka mirror-maker consumer config file: $consumer_ssl_config_file *Has not been created yet!"
  [[ -f $producer_ssl_config_file ]] \
  && display_info "kafka mirror-maker consumer config file: $producer_ssl_config_file" \
  || display_warn "kafka mirror-maker consumer config file: $producer_ssl_config_file *Has not been created yet!"
  display_break

  display_H1 "Kafka Configuration Templates:"
  display_info "kafka configuration templates location: $kafka_templates_config_dir"
  display_info "kafka broker config template file: $broker_config_template_file"
  display_info "kafka zookeeper config template file: $zookeeper_config_template_file"
  display_info "kafka mirror-maker producer config template file: $mm_producer_config_template_file"
  display_info "kafka mirror-maker consumer config template file: $mm_consumer_config_template_file"
  display_info "kafka console-consumer ssl config template file: $consumer_ssl_config_template_file"
  display_info "kafka console-producer ssl config template file: $producer_ssl_config_template_file"
  display_break

  display_H1 "Kafka Logs:"
  [[ -d $kafka_broker_logs_dir ]] \
  && display_info "kafka persistent broker logs location: $kafka_broker_logs_dir" \
  || display_warn "kafka persistent broker logs location: $kafka_broker_logs_dir *Has not been created yet!"
  [[ -d $zookeeper_logs_dir ]] \
  && display_info "kafka persistent zookeeper logs location: $zookeeper_logs_dir" \
  || display_warn "kafka persistent zookeeper logs location: $zookeeper_logs_dir *Has not been created yet!"
  [[ -d $kafka_runtime_console_logs_dir ]] \
  && display_info "kafka persistent runtime logs directory: $kafka_runtime_console_logs_dir" \
  || display_warn "kafka persistent logs directory: $kafka_runtime_console_logs_dir *Has not been created yet!"

  # display_info "kafka broker runtime console log: $broker_runtime_console_log_file"
  # display_warn "kafka broker runtime console log: $broker_runtime_console_log_file *Has not been created yet!"
  #
  # display_info "kafka zookeeper runtime console log: $zookeeper_runtime_console_log_file"
  # display_warn "kafka zookeeper runtime console log: $zookeeper_runtime_console_log_file *Has not been created yet!"

  if [ `find $kafka_runtime_console_logs_dir -name '*broker*'| wc -l` -gt 0 ]; then
    for each in `find $kafka_runtime_console_logs_dir -name '*broker*'`; do
      display_info "kafka broker console log file found : $each"
    done
  else
    display_warn "No kafka broker console log files found. *Has not been created yet!"
  fi

  if [ `find $kafka_runtime_console_logs_dir -name '*zookeeper*'| wc -l` -gt 0 ]; then
    for each in `find $kafka_runtime_console_logs_dir -name '*zookeeper*'`; do
      display_info "kafka zookeeper console log file found: $each"
    done
  else
    display_warn "No kafka zookeeper console log files found. *Has not been created yet!"
  fi

  [[ -f $mm_runtime_console_log_file ]] \
  && display_info "kafka mirror-maker runtime console log: $mm_runtime_console_log_file" \
  || display_warn "kafka mirror-maker runtime console log: $mm_runtime_console_log_file *Has not been created yet!"
  display_break

  display_H1 "Kafka Cluster Status:"
  check_zookeper_status
  check_broker_status
  check_mirror_maker_status

}
