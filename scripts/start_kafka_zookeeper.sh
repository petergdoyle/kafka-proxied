#!/bin/sh
cd $(dirname $0)
. ./build_kafka_configuration.sh

ZK_PIDS=`ps ax | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`

if [ ! -z $ZK_PIDS ]; then\
  display_error "zookeeper is already running ! stop the cluster first !"
  exit 1
fi

if [ ! -d $kafka_runtime_config_dir ]; then
  mkdir -pv $kafka_runtime_config_dir
fi

if [ ! -d $kafka_runtime_console_logs_dir ]; then
  mkdir -pv $kafka_runtime_console_logs_dir
fi

if [ ! -f $zookeeper_config_template_file ]; then
  "cannot continue. no template file named $zookeeper_config_template_file exists"
  exit 1
fi

no_instances="1"
read -e -p "Enter the number of zookeeper instances: " -i "$no_instances" no_instances
for i in $(eval echo "{1..$no_instances}"); do
  zookeeper_id=$node_name-$i
  read -e -p "Confirm the Zookeeper Id (must be unique within the cluster): " -i "$zookeeper_id" zookeeper_id
  configure_zookeeper
  zookeeper_config_file="$kafka_runtime_config_dir/$zookeeper_id-zk-config.properties"
  cp -vf $zookeeper_config_template_file  $zookeeper_config_file
  sed -i "s/clientPort=.*/clientPort=$zk_port/g" $zookeeper_config_file
  zookeeper_runtime_console_log_file="$kafka_base_location/logs/$zookeeper_id-zk-console.log"

  cmd="$KAFKA_HOME/bin/zookeeper-server-start.sh $zookeeper_config_file> $zookeeper_runtime_console_log_file 2>&1"
  echo "$cmd"
  prompt=$BOLD$YELLOW"About to start Zookeeper instance $i, continue? (y/n): $RESET"
  default_value="y"
  read -e -p "$(echo -e $prompt)" -i $default_value response
  if [ "$response" != 'y' ]; then
      exit 0
  fi

  eval "$cmd" &
  sleep 2
  PIDS=`ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`
  if [[ ! -z $PIDS ]]; then
    prompt="Tail on log file ($zookeeper_runtime_console_log_file)? (y/n): "
    default_value="y"
    read -e -p "$prompt" -i $default_value response
    if [ "$response" == 'y' ]; then
      timeout 5s tail -f "$zookeeper_runtime_console_log_file"
    fi
  else
    display_error "zookeeper does not appear to be running"
    sleep 2
    if [ -f $zookeeper_runtime_console_log_file ]; then
      less -f $zookeeper_runtime_console_log_file
    fi
  fi

done
