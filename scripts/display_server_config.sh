#!/bin/sh
cd $(dirname $0)
. ./common.sh

grep -v "^#" $broker_config_file|awk 'NF'
