#!/bin/bash
cd $(dirname $0) 
. ../common.sh

PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

if [ -z "$PIDS" ]; then
  display_error "No kafka broker process(es) found to stop"
  exit 0
else
  for each in $PIDS; do
    msg="about to kill process(es): $each"
    display_warn $msg
    sleep 1
    kill -9 $each
  done
fi
