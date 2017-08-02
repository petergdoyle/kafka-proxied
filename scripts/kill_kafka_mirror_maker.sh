#!/bin/sh
cd $(dirname $0)

PIDS=$(ps ax | grep java | grep -i MirrorMaker | grep -v grep | awk '{print $1}')

msg="about to kill process(es): $PIDS..."
echo -e "\e[7;40;92m$msg\e[0m"
sleep 1

if [ -z "$PIDS" ]; then
  echo "No mirror-maker to stop"
  exit 1
else
  kill -9 TERM $PIDS
fi
