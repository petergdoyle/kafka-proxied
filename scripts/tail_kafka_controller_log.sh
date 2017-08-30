#!/bin/sh
cd $(dirname $0)
. ./common.sh

cmd="tail -f $kafka_controller_log_file"
display_command "$cmd"
eval "$cmd"
