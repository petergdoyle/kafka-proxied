#!/bin/sh
cd $(dirname $0)

ps ax |grep -v grep |grep java |grep -i 'kafka\.Kafka' > /dev/null 2>&1
if [ $? -eq 0 ]; then
  $KAFKA_HOME/bin/kafka-server-stop.sh
  sleep 1
fi

ps ax |grep -v grep |grep java |grep -i 'zookeeper' > /dev/null 2>&1
if [ $? -eq 0 ]; then
  $KAFKA_HOME/bin/zookeeper-server-stop.sh
fi
