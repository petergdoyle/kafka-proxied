#!/bin/sh
cd $(dirname $0)
. ./build_kafka_configuration.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

create_mirror_maker_config

topic='kafka-simple-topic-1'
read -e -p "Enter the topic name: " -i "$topic" topic

consumer_group='".*”'
cmd=$KAFKA_HOME'/bin/kafka-mirror-maker.sh --consumer.config '$mm_consumer_config_file' --producer.config '$mm_producer_config_file' --whitelist="'$topic'"> '$mm_runtime_console_log_file' 2>&1'
display_command "$cmd"
# prompt=$BOLD$YELLOW"About to start Mirror-Maker, continue? (y/n): $RESET"
# default_value="y"
# read -e -p "$(echo -e $prompt)" -i $default_value response
# if [ "$response" == 'y' ]; then
#   eval "$cmd" &
# fi
#
# sleep 2
# PIDS=`ps ax | grep -i MirrorMaker | grep -v grep | awk '{print $1}'`
# if [ ! -z $PIDS ]; then
#   prompt="Tail on log file ($mm_consumer_config_file)? (y/n): "
#   default_value="y"
#   read -e -p "$prompt" -i $default_value response
#   if [ "$response" == 'y' ]; then
#     timeout 5s tail -f "$mm_consumer_config_file"
#   fi
# else
#   display_error "Mirror-Maker does not appear to be running"
# fi
