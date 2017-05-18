#!/bin/sh
cd $(dirname $0)

PIDS=`ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'`

msg="Zookeeper process(es): $PIDS..."
echo -e "\e[7;40;92m$msg\e[0m"
