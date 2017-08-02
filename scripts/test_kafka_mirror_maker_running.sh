#!/bin/sh
cd $(dirname $0)

PIDS=`ps ax | grep java | grep -i MirrorMaker | grep -v grep | awk '{print $1}'`

msg="MirrorMaker process(es): $PIDS"
echo -e "\e[7;40;92m$msg\e[0m"
