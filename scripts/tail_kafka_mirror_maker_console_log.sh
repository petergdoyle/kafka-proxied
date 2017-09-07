#!/bin/sh
cd $(dirname $0)
. ./common.sh

MM_PIDS=`ps ax | grep -i MirrorMaker | grep -v grep | awk '{print $1}'`

if [[ -z $MM_PIDS ]]; then\
  display_error "Warning MirrorMaker is not running"
fi

tail -f "$mm_runtime_console_log_file"
