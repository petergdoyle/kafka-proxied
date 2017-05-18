#!/bin/sh
cd $(dirname $0)

PIDS=`ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}'`

msg="Kakfa process(es): $PIDS..."
echo -e "\e[7;40;92m$msg\e[0m"
