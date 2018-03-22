#!/bin/bash
cd $(dirname $0)
. ../common.sh

ZK_PIDS=$(ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}')

if [ -z "$ZK_PIDS" ]; then
  display_error "No kafka zookeeper process(es) found to stop"
  exit 0
else
  for each in $ZK_PIDS; do
    display_warn "about to terminate process ${each}..."
    sleep 1
    if kill -TERM $each ; then
	display_info "Terminated process ${each}."
    else
	display_error "Failed to terminate process ${each}!"
    fi
  done
fi
