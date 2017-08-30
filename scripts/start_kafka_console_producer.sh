#!/bin/sh
cd $(dirname $0)
. ./common.sh

if [ -z $KAFKA_HOME ]; then
  echo "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

bootstrap_server='localhost:9091'
read -e -p "Enter a kafka broker server: " -i "$bootstrap_server" bootstrap_server

topic='kafka-simple-topic-1'
read -e -p "Enter the topic name: " -i "$topic" topic


producer_ssl_config=""

response='n'
read -e -p "Do you need to configure SSL for this Kafka bootstrap server (y/n): " -i "$response" response
if [ "$response" == "y" ]; then
  truststore_location=$PWD/$(echo $bootstrap_server |cut -d: -f1).truststore.jks
  while true; do
    read -e -p "Specify the truststore location: " -i "$truststore_location" truststore_location
    if [ -f $truststore_location ]; then
      break
    else
      display_error "Specified file $truststore_location does not exist"
    fi
  done

  cp -vf $producer_ssl_config_template_file $producer_ssl_config_file

  truststore_password="majiic"
  read -e -p "Specify the truststore password: " -i "$truststore_password" truststore_password
  sed -i "s?ssl.truststore.location=#REPLACE#?ssl.truststore.location=$truststore_location?g" $producer_ssl_config_file
  sed -i "s/ssl.truststore.password=#REPLACE#/ssl.truststore.password=$truststore_password/g" $producer_ssl_config_file

  producer_ssl_config="--producer.config $producer_ssl_config_file"
fi

cmd="$KAFKA_HOME/bin/kafka-console-producer.sh $producer_ssl_config --broker-list $bootstrap_server --topic $topic"

display_command "$cmd"
eval "$cmd"
