#!/bin/sh
cd $(dirname $0)

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

node_name=`hostname |grep -io broker[0-9] |awk '{print tolower($0)}'`
host_name=`hostname| cut -d"." -f1`

kafka_version="10.0.1"
broker_config_file="not found"
while [ ! -f "$broker_config_file" ]; do
  read -e -p "Confirm Kafka Version: " -i "$kafka_version" kafka_version
  broker_config_file=`find config/ -name "$node_name*$kafka_version*"`
done

sudo cp -v config/* /usr/kafka/default/config/

mkdir -p $PWD/logs/$node_name/
broker_log_file="$PWD/logs/$node_name/kafka_broker_console.log"
cmd="$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/$broker_config_file > $broker_log_file 2>&1"
echo "$cmd"
eval "$cmd" &
echo "Output will be redirected to $broker_log_file"
sleep 3
ps aux |grep java |grep --color -v grep
sleep 1
tail -f "$broker_log_file"
