#!/bin/sh
. ./common.sh

if [[ $EUID -ne 0 ]]; then #check if run as root
  display_error "must be run as root"
  return 1
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

function add_rich_rules() {

  # firewall-cmd --permanent --new-zone=azure
  # #40.78.64.141 (HospitalityHertzPocNode0-ip)
  # firewall-cmd --permanent --zone=azure --add-source=216.113.139.2
  # #40.112.255.211 (HospitalityHertzPocNode1-ip)
  # firewall-cmd --permanent --zone=azure --add-source=40.112.255.211
  # firewall-cmd --permanent --zone=azue --add-rich-rule='rule family=ipv4 source address=40.78.64.141 port port=12181 protocol=tcp accept'
  # firewall-cmd --permanent --zone=azue --add-rich-rule='rule family=ipv4 source address=40.78.64.141 port port=19091-19093 protocol=tcp accept'
  # firewall-cmd --permanent --zone=azue --add-rich-rule='rule family=ipv4 source address=40.112.255.211 port port=12181 protocol=tcp accept'
  # firewall-cmd --permanent --zone=azue --add-rich-rule='rule family=ipv4 source address=40.112.255.211 port port=19091-19093 protocol=tcp accept'

  while true; do
    local ip="192.168.1.82"
    read -e -p "Enter the inbound IP number: " -i "$ip" ip
    local port="19091"
    read -e -p "Enter the inbound port to open (range allowed - 19091-19093): " -i "$port" port
    cmd="firewall-cmd --zone=public --add-rich-rule='rule family=ipv4 source address=$ip port port=$port protocol=tcp accept'"
    echo "about to run command: $cmd"
    eval "$cmd"
    local response="y"
    read -e -p "Enter another firewall rule? (y/n): " -i "$response" response
    if [ $response != "y" ]; then
      break
    fi
  done

}
