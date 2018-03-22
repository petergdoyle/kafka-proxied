#!/bin/bash

display_interfaces=`ifconfig |grep '^[a-z]'|awk '{print $1}'| sed 's/.$//'| tr '\n' '  '`
echo "Network interfaces: $display_interfaces"
read -e -p "Enter the network interface: " -i "$interface" interface

read -e -p "Enter the remote IP to listen for packets: " -i "$ip" ip

sudo tcpdump -i $interface -nnvXSs 0 dst $ip
