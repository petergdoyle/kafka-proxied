#!/bin/sh
cd $(dirname $0)
. ../common.sh

ZK_PIDS=$(ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}')

if [ -z "$ZK_PIDS" ]; then
  display_error "No kafka zookeeper process(es) found to stop"
  exit 0
else
  for each in $ZK_PIDS; do
    msg="about to kill process(es): $each"
    echo -e $msg
    sleep 1
    kill -9 $each
  done
fi
