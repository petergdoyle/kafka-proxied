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

# read -e -p "Start kafka with which node?: " -i "`hostname |grep -io node[0-9] |awk '{print tolower($0)}'`" node
node_name=`hostname| cut -d"." -f1`
mkdir -p $PWD/logs/$node_name/
zk_log_file="$PWD/logs/$node_name/kafka_zookeeper_console.log"
cmd="$KAFKA_HOME/bin/zookeeper-server-start.sh $KAFKA_HOME/config/zookeeper.properties > $zk_log_file 2>&1"
echo "$cmd"
eval "$cmd" &
echo "Output will be redirected to $zk_log_file"
