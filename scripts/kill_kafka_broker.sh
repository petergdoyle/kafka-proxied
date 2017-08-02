#!/bin/sh


PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

msg="about to kill process(es): $PIDS..."
echo -e "\e[7;40;92m$msg\e[0m"
sleep 1

if [ -z "$PIDS" ]; then
  echo "No kafka broker to stop"
  exit 1
else
  kill -9 TERM $PIDS
fi
