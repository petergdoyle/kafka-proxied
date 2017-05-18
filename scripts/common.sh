#!/bin/sh

host_name=`hostname| cut -d"." -f1`
node_name=`echo $host_name |grep -Eo "broker[0-9]|zookeeper[0-9]" |awk '{print tolower($0)}'| grep '.*'`

RESET="\033[0m"
BOLD="\033[1m"
YELLOW="\033[38;5;11m"
GREEN="\033[32m"

function confirm_execute() {
  local cmd="$1"
  prompt=`echo -e $GREEN"About to run the command:\n$YELLOW$cmd$RESET$GREEN\ncontinue (y/n)? "`
  read -e -p "$prompt" -i "y" run_it
  echo -e $RESET
  if [ "$run_it" == "y" ]; then
    eval "$cmd" 
  fi
}
