#!/bin/bash
cd $(dirname $0) 
. ../common.sh

PIDS=$(ps ax | grep java | grep -i MirrorMaker | grep -v grep | awk '{print $1}')

if [ -z "$PIDS" ]; then
  display_error "No kafka mirror-maker process(es) found to stop"
  exit 0
else
  for each in $PIDS; do
    msg="about to kill process(es): $each"
    display_warn $msg
    sleep 1
    kill -9 TERM $each
  done
fi
