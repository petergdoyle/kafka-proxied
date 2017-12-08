#!/bin/sh

if [[ $EUID -ne 0 ]]; then
  display_error "This script must be run as root"
  exit 1
fi

sudo yum -y install epel-release nodejs
