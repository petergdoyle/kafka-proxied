#!/bin/sh


PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

if [ -z "$PIDS" ]; then
  echo "No kafka broker to stop"
  exit 1
else
  kill -s TERM $PIDS
fi
