#!/bin/sh
cd $(dirname $0)

ps ax | grep java | grep -i MirrorMaker | grep -v grep | awk '{print $1}'
