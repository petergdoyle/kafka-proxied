#!/bin/bash

display_interfaces=`ifconfig |grep '^[a-z]'|awk '{print $1}'| sed 's/.$//'| tr '\n' '  '`
echo "Network interfaces: $display_interfaces"
read -e -p "Enter the local network interface to listen on: " -i "$interface" interface
read -e -p "Enter the remote IP to listen for packets: " -i "$ip" ip

cmd="sudo tcpdump -i $interface -nnvXSs 0 dst $ip"
display_command "$cmd"

prompt=$BOLD$YELLOW"About to run command as shown, continue? (y/n): $RESET"
default_value="y"
read -e -p "$(echo -e $prompt)" -i $default_value response
if [ "$response" == 'y' ]; then
  eval "$cmd"
fi
