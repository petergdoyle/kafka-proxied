#!/bin/sh
cd $(dirname $0)
. ./common.sh

MM_PIDS=`ps ax | grep -i MirrorMaker | grep -v grep | awk '{print $1}'`

if [[ -z $MM_PIDS ]]; then\
  display_error "Warning MirrorMaker is not running"
fi

if [ ! -f $mm_runtime_console_log_file ]; then
  display_error "the file $mm_runtime_console_log_file does not exist."
  exit 1
fi

tail -f "$mm_runtime_console_log_file"
