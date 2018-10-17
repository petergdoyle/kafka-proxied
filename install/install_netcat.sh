#!/bin/bash

if [[ $EUID -ne 0 ]]; then #check if run as root
  display_error "must be run as root"
  exit    1
fi

yum -y install nmap-ncat
