#!/bin/sh
cd $(dirname $0)
. ./common.sh

ZK_PIDS=`ps ax | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`

if [ -z $ZK_PIDS ]; then\
  display_error "zookeeper is not running ! start the cluster first !"
  exit 1
fi

tail -f "$zookeeper_runtime_console_log_file"
