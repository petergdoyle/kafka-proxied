#!/bin/bash
cd $(dirname $0)
. ./kafka_common.sh

nc > /dev/null 2>&1
if [ $? -eq 127 ]; then
  echo "The netcat utility (nc) doesn't seem to be installed. If you are on Centos or Redhat, run kafka-proxied/install/install_netcat.sh, otherwise check your linux distro for instructions how to install the nc command."
  exit 1
fi

#prompt for host to scan
host_name='remotehost'
read -e -p "Enter the host name (or ip number): " -i "$host_name" host_name

#create an array to hold port numbers
ports=()
#prompt for port numbers to scan
port='2181'
#add port to port array
while true; do
  read -e -p "Enter a port to scan $host_name: " -i "$port" port
  ports=("${ports[@]}" "$port")
  response="y"
  read -e -p "Enter another port? (y/n): " -i "$response" response
  if [ $response != "y" ]; then
    break
  fi
done

#display ports to scan
echo "The host $host_name will be scanned on port(s): ${ports[@]}..."


nc_opt1=' -w 1' #limit timeouts to 1 second
nc_opt2=' -n' #refuse delays for reverse DNS lookups
nc_opt3=' -v' #verbose output
nc_opt4=' -z' #Zero-I/O mode, report connection status only
for each in "${ports[@]}"; do
  nc $nc_opt1 $nc_opt2 $nc_opt3 $nc_opt4 $host_name $each
done
