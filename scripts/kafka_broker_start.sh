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

sudo cp -v config/* /usr/kafka/default/config/
node_name=`hostname |grep -io broker[0-9] |awk '{print tolower($0)}'`
host_name=`hostname| cut -d"." -f1`
mkdir -p $PWD/logs/$node_name/
broker_log_file="$PWD/logs/$node_name/kafka_broker_console.log"
cmd="$KAFKA_HOME/bin/kafka-server-start.sh $KAFKA_HOME/config/$node_name.properties > $broker_log_file 2>&1"
echo "$cmd"
eval "$cmd" &
echo "Output will be redirected to $broker_log_file"
sleep 3
ps aux |grep java
