#!/bin/sh
cd $(dirname $0)
. ./common.sh

BKR_PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep -v grep | awk '{print $1}'`

if [ -z $BKR_PIDS ]; then\
  display_error "broker is not running ! stop the broker first !"
  exit 1
fi


tail -f "$broker_runtime_console_log_file"
