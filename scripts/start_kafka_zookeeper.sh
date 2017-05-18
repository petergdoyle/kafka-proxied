#!/bin/sh
cd $(dirname $0)
. ./common.sh
. ./install_kafka.sh
. ./build_kafka_configuration.sh

if [ -d /tmp/kafka-logs ]; then
  read -e -p "Destroy old logs? (y/n): " -i "y" response
  if [ "$response" == 'y' ]; then
    rm -frv /tmp/kafka-logs
    sudo rm -frv $KAFKA_HOME/logs
  fi
fi

if [ -d /tmp/zookeeper ]; then
  read -e -p "Destroy old Topics? (y/n): " -i "y" response
  if [ "$response" == 'y' ]; then
    rm -frv /tmp/zookeeper
  fi
fi

create_zookeeper_config

mkdir -p $PWD/../local/logs/$node_name/
zk_log_file="$PWD/../local/logs/$node_name/kafka_zookeeper_console.log"
cmd="$KAFKA_HOME/bin/zookeeper-server-start.sh $zookeeper_config_file> $zk_log_file 2>&1"
echo "$cmd"
eval "$cmd" &
echo "Output will be redirected to $zk_log_file"
sleep 1
ps ax | grep java | grep -i QuorumPeerMain | grep -v grep
sleep 1
tail -f "$zk_log_file"
