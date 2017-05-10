#!/bin/sh
cd $(dirname $0)

ps ax | grep java | grep -i QuorumPeerMain | grep -v grep | awk '{print $1}'
