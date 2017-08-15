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

  # firewall-cmd --zone=public --permanent --new-zone=azure
  # #40.78.64.141 (HospitalityHertzPocNode0-ip)
  # firewall-cmd --zone=public --permanent --zone=azure --add-source=216.113.139.2
  # #40.112.255.211 (HospitalityHertzPocNode1-ip)
  # firewall-cmd --zone=public --permanent --zone=azure --add-source=40.112.255.211
  firewall-cmd --list-all |grep 'rule family'
  local ip="192.168.1.80/90"
  while true; do
    read -e -p "Enter the inbound IP number: " -i "$ip" ip
    local port="9091"
    read -e -p "Enter the inbound port to open (range allowed - 9091-9093): " -i "$port" port
    cmd="firewall-cmd --zone=public --add-rich-rule='rule family=ipv4 source address=$ip port port=$port protocol=tcp accept'"
    echo "about to run command: $cmd"
    eval "$cmd"
    local response="y"
    read -e -p "Enter another firewall rich-rule? (y/n): " -i "$response" response
    if [ $response != "y" ]; then
      break
    fi
  done

}

# function remove_rich_rules() {
#
#     firewall-cmd --list-all |grep 'rule family'
#     local ip="192.168.1.80/90"
#     while true; do
#       read -e -p "Enter the inbound IP number: " -i "$ip" ip
#       local port="9091"
#       read -e -p "Enter the inbound port to open (range allowed - 9091-9093): " -i "$port" port
#       cmd="firewall-cmd --zone=public --remove-rich-rule='rule family=ipv4 source address=$ip port port=\"$port\" protocol=tcp accept'"
#       echo "about to run command: $cmd"
#       eval "$cmd"
#       local response="y"
#       read -e -p "Remove another firewall rich-rule? (y/n): " -i "$response" response
#       if [ $response != "y" ]; then
#         break
#       fi
#     done
#
# }

function list_rich_rules() {
  OLD_IFS=$IFS
  IFS=$'\n'
  for each in `firewall-cmd --list-all |grep 'rule family'| sed -e 's/^[ \t]*//'`; do
    echo firewall-cmd --zone=public --permanent --add-rich-rule=\'"$each"\'
  done
  IFS=$OLD_IFS
}

function remove_rich_rules() {
  list_rich_rules| sed s/--add-rich-rule/--remove-rich-rule/g
}


# all
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.81" port port="9091-9093" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.82" port port="9091-9093" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.83" port port="9091-9093" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="40.112.255.211" port port="9091-9093" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="40.78.64.141" port port="9091-9093" protocol="tcp" accept'

firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.81" port port="19091-19093" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.82" port port="19091-19093" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.83" port port="19091-19093" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="40.112.255.211" port port="19091-19093" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="40.78.64.141" port port="19091-19093" protocol="tcp" accept'

firewall-cmd --zone=public --add-masquerade --permanent

# engine1
firewall-cmd --zone=public --permanent --add-forward-port=port=12181:proto=tcp:toport=2181
firewall-cmd --zone=public --permanent --add-forward-port=port=19091:proto=tcp:toport=9091
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.81" port port="2181" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.82" port port="2181" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.83" port port="2181" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="40.78.64.141" port port="2181" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="40.112.255.211" port port="2181" protocol="tcp" accept'

firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.81" port port="12181" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.82" port port="12181" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="192.168.1.83" port port="12181" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="40.78.64.141" port port="12181" protocol="tcp" accept'
firewall-cmd --zone=public --permanent --add-rich-rule='rule family="ipv4" source address="40.112.255.211" port port="12181" protocol="tcp" accept'

# engine2
firewall-cmd --zone=public --add-forward-port=port=19092:proto=tcp:toport=9092

# engine3
firewall-cmd --zone=public --add-forward-port=port=19093:proto=tcp:toport=9093
