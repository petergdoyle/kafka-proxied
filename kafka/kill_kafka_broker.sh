#!/bin/bash
cd $(dirname $0) 
. ../common.sh

PIDS=$(ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}')

if [ -z "$PIDS" ]; then
  display_error "No kafka broker process(es) found to stop."
  exit 0
else
  for each in $PIDS; do
    display_warn "about to terminate process ${each}..."
    sleep 1
    if kill -TERM $each ; then
	display_info "Terminated process ${each}."
    else
	display_error "Failed to terminate process ${each}!"
    fi
  done
fi
