#!/bin/sh
cd $(dirname $0)
. ./common.sh
. ./build_kafka_configuration.sh

create_mirror_maker_config

topic='topic-a'
read -e -p "Enter the topic name: " -i "$topic" topic

consumer_group='".*”'
cmd=$KAFKA_HOME'/bin/kafka-mirror-maker.sh --consumer.config '$mm_consumer_config_file' --producer.config '$mm_producer_config_file' --whitelist="'$topic'"> '$mm_runtime_console_log_file' 2>&1'
echo "$cmd"
eval "$cmd"
echo "Output will be redirected to $mm_runtime_console_log_file"
