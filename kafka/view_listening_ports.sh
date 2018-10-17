#!/bin/bash
cd $(dirname $0)
. ../common.sh

if [[ $EUID -ne 0 ]]; then #check if run as root
  display_error "must be run as root"
  exit    1
fi

netstat -tulpn |grep LISTEN
