#!/bin/sh
cd $(dirname $0)
source ./install_kafka.sh
source ./build_kafka_configuration.sh

create_mirror_maker_config

consumer_group='".*”'
mkdir -p $PWD/logs/$node/
mm_log_file="$PWD/logs/$node/kafka_mirrormaker_console.log"
cmd="$KAFKA_HOME/bin/kafka-mirror-maker.sh \
--consumer.config $KAFKA_HOME/config/mm_consumer.properties \
--producer.config $KAFKA_HOME/config/mm_producer.properties \
--whitelist="'"hertz-edifact"'"  \
> $mm_log_file 2>&1"
echo "$cmd"
# eval "$cmd" &
# echo "Output will be redirected to $mm_log_file"
