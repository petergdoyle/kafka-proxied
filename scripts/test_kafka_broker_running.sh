#!/bin/sh
cd $(dirname $0)
. ./common.sh

PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}'`

if [ ! -z $PIDS ]; then

  msg="Zookeeper process(es): $PIDS"
  display_info $msg

else
  display_error "No broker process(es) appear to be running"
fi
