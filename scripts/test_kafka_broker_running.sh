#!/bin/sh
cd $(dirname $0)

ps ax | grep -i 'kafka\.Kafka' | grep java | grep -v grep | awk '{print $1}'
