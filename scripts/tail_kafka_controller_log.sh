#!/bin/sh
cd $(dirname $0)
. ./common.sh

if [ ! -f $kafka_controller_log_file ]; then
  display_error "the file $kafka_controller_log_file does not exist."
  exit 1
fi
cmd="tail -f $kafka_controller_log_file"
display_command "$cmd"
eval "$cmd"
