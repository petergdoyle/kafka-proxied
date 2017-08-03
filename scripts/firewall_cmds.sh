#!/bin/sh
cd $(dirname $0)
. ./common.sh

if [[ $EUID -ne 0 ]]; then #check if run as root 
  display_error "must be run as root"
fi

function firewall_on () {
  firewall-cmd --zone=public --add-port=12181/tcp
  firewall-cmd --zone=public --add-port=19091/tcp
  firewall-cmd --zone=public --add-port=19092/tcp
}

function firewall_off () {
  firewall-cmd --zone=public --remove-port=12181/tcp
  firewall-cmd --zone=public --remove-port=19091/tcp
  firewall-cmd --zone=public --remove-port=19092/tcp
}
