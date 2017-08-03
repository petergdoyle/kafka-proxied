#!/bin/sh
cd $(dirname $0)
. ./common.sh

PIDS=`ps ax | grep java | grep -i MirrorMaker | grep -v grep | awk '{print $1}'`


if [ ! -z $PIDS ]; then

  msg="Miror-Maker process(es): $PIDS"
  display_info $msg

else
  display_error "No mirror-maker process(es) appear to be running"
fi
