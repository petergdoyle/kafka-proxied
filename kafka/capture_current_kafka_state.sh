#!/bin/sh
cd $(dirname $0) 
. ./build_kafka_configuration.sh

capture_kafka
