#!/bin/bash
cd $(dirname $0)
. ./kafka_common.sh

current_log_level=`cat $kafka_tools_log4j_file |awk -F'rootLogger=' '{print $2}'|awk NF| cut -f 1 -d ','`
echo $current_log_level
