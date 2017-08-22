#!/bin/sh
cd $(dirname $0)
. ./common.sh

cmd="tail -f $kafka_controller_log_file"
echo "$cmd"
eval "$cmd"
