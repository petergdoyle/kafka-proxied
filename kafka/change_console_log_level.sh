#!/bin/bash
cd $(dirname $0)
. ./kafka_common.sh

function display_log_level() {
  current_log_level=`cat $kafka_tools_log4j_file |awk -F'rootLogger=' '{print $2}'|awk NF| cut -f 1 -d ','`
  echo "current console-tools log-level: $current_log_level"
}
display_log_level
read -e -p "Change log level from $current_log_level? (y/n): " -i "$response" response
if [ $response == "y" ]; then
  if [ "$current_log_level" == "WARN" ]; then
      sed -i -e "s/log4j.rootLogger=WARN/log4j.rootLogger=INFO/g" $kafka_tools_log4j_file
  else
      sed -i -e "s/log4j.rootLogger=INFO/log4j.rootLogger=WARN/g" $kafka_tools_log4j_file
  fi
  display_log_level
fi
