#!/bin/sh
cd $(dirname $0) 
. ../common.sh

if [[ $EUID -ne 0 ]]; then
  display_error "This script must be run as root"
  exit 1
fi

prompt=$BOLD$YELLOW"About to modify firewall rules. Continue (y/n): $RESET"
default_value="y"
read -e -p "$(echo -e $prompt)" -i $default_value response
if [ "$response" != 'y' ]; then
  exit 0
fi

permanent=""

firewall-cmd --zone=public $permanent --add-masquerade

no_instances="1"
read -e -p "Enter the number of broker instances: " -i "$no_instances" no_instances

firewall-cmd --zone=public $permanent --add-forward-port=port=9091:proto=tcp:toaddr=192.168.1.81
