#!/bin/sh
cd $(dirname $0)
. ./common.sh
. ./build_kafka_configuration.sh

cleanup_kafka
