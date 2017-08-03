#!/bin/sh
cd $(dirname $0)
. ./build_kafka_configuration.sh

cleanup_kafka
