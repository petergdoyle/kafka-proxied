#!/bin/bash

. ../../common.sh

if [ -z $KAFKA_HOME ]; then
  display_error "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

function start_zookeeper() {

  ZK_PIDS=$(ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}')

  if [ -z "$ZK_PIDS" ]; then

    $KAFKA_HOME/bin/zookeeper-server-start.sh \
    $KAFKA_HOME/config/kafka-proxied-zookeeper-1-config.properties \
    > $KAFKA_HOME/logs/kafka-proxied-zookeeper-1-console.log 2>&1

    ZK_PIDS=$(ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}')
    display_info "kafka zookeeper process now running: $ZK_PIDS"

  else
    display_warn "kafka zookeeper process(es) are already running: $ZK_PIDS"
  fi

}

function start_broker() {

  BKR_PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

  if [ -z "$PIDS" ]; then

    $KAFKA_HOME/bin/kafka-server-start.sh \
    $KAFKA_HOME/config/kafka-proxied-broker-1.properties \
    > $KAFKA_HOME/logs/kafka-proxied-broker-1-console.log 2>&1

    BKR_PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')
    display_info "kafka broker process now running: $ZK_PIDS"

  else
    display_warn "kafka broker process(es) are already running: $BKR_PIDS"
  fi
}

function create_topic() {

  $KAFKA_HOME/bin/kafka-topics.sh \
  --create --zookeeper localhost:2181 --replication-factor 1 \
  --partitions 1 --topic kafka-simple-topic-1 --config max.message.bytes=262144 \
  --config retention.bytes=26214400 --config retention.ms=3600000

}

start_zookeeper
sleep 1
start_broker
sleep 1
