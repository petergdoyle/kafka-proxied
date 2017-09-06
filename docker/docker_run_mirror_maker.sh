#!/bin/sh

cmd="bin/kafka-mirror-maker.sh \
--consumer.config /config/kafka-proxied-mm_consumer.properties \
--producer.config /vagrant/local/kafka/config/kafka-proxied-mm_producer.properties \
--whitelist=\"kafka-simple-topic-1\""
