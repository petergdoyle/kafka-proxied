#!/bin/sh

PIDS=$(ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}')

if [ -z "$PIDS" ]; then
  echo "No kafka zookeeper to stop"
  exit 1
else
  kill -s TERM $PIDS
fi
