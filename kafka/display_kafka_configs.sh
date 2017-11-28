#!/bin/sh
cd $(dirname $0)
. ./kafka_common.sh

files_found=`find $kafka_runtime_config_dir -type f -name '*properties'|wc -l`
# selected_broker='1'
# if [ $files_found -gt 1 ]; then
#   read -e -p "A total of $files_found broker config file(s) found. Which broker (number)?: " -i "$selected_broker" selected_broker
# fi

for each in `find $kafka_runtime_config_dir -type f -name '*properties'`; do
  echo "--- $each ---"
  grep -v "^#" $each|awk 'NF'
done
