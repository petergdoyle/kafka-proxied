#!/bin/sh
cd $(dirname $0)
. ./build_kafka_configuration.sh

ZK_PIDS=`ps ax | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`

if [ ! -z $ZK_PIDS ]; then\
  display_error "zookeeper is already running ! stop the cluster first !"
  exit 1
fi

create_zookeeper_config

cmd="$KAFKA_HOME/bin/zookeeper-server-start.sh $zookeeper_config_file> $zookeeper_runtime_console_log_file 2>&1"
echo "$cmd"
prompt=$BOLD$YELLOW"About to start Zookeeper, continue? (y/n): $RESET"
default_value="y"
read -e -p "$(echo -e $prompt)" -i $default_value response
if [ "$response" != 'y' ]; then
    exit 0
fi

eval "$cmd" &
sleep 2
PIDS=`ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`
if [ ! -z $PIDS ]; then
  prompt="Tail on log file ($zookeeper_runtime_console_log_file)? (y/n): "
  default_value="y"
  read -e -p "$prompt" -i $default_value response
  if [ "$response" == 'y' ]; then
    tail -f "$zookeeper_runtime_console_log_file"
  fi
else
  display_error "zookeeper does not appear to be running"
fi
