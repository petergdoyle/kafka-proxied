#!/bin/sh

PIDS=$(ps ax | grep java | grep -i MirrorMaker | grep -v grep | awk '{print $1}')

if [ -z "$PIDS" ]; then
  echo "No kafka mirror-maker process(es) found to stop"
  exit 0
else
  for each in $PIDS; do
    msg="about to kill process(es): $each"
    echo -e "\e[7;40;92m$msg\e[0m"
    sleep 1
    kill -9 TERM $each
  done
fi
