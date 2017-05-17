#!/bin/sh
cd $(dirname $0)

PIDS=$(ps ax | grep java | grep -i MirrorMaker | grep -v grep | awk '{print $1}')

if [ -z "$PIDS" ]; then
  echo "No mirror-maker to stop"
  exit 1
else
  kill -s TERM $PIDS
fi