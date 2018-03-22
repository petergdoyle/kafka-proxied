#!/bin/bash

. ../kafka/kafka_common.sh
set_kafka_variables

if [ ! -d $kafka_installation_dir ]; then
  display_error "Kafka is not installed. Run install_kafka script."
  exit 1
fi

if [ -z $KAFKA_HOME ]; then
  display_error "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi

no_cache=""
if [ "$1" == "--clean" ]; then
  no_cache="--no-cache"
fi


if [ -d kafka ]; then
  rm -frv kafka
fi

mkdir -pv kafka/
cp -vr $KAFKA_HOME/* kafka/

mm_consumer_config_template_file="$kafka_config_dir/$kafka_version/mm_consumer-template.properties"
mm_producer_config_template_file="$kafka_config_dir/$kafka_version/mm_producer-template.properties"

mm_consumer_config_file="$PWD/kafka/config/mm_consumer.properties"
mm_producer_config_file="$PWD/kafka/config/mm_producer.properties"

cp -vf $mm_consumer_config_template_file $mm_consumer_config_file
cp -vf $mm_producer_config_template_file $mm_producer_config_file

display_info "kafka_config_dir: $kafka_config_dir"
display_info "kafka_version: $kafka_version"
display_info "mm_consumer_config_template_file: $mm_consumer_config_template_file"
display_info "mm_producer_config_template_file: $mm_producer_config_template_file"
display_info "mm_consumer_config_file: $mm_consumer_config_file"
display_info "mm_producer_config_file: $mm_producer_config_file"

configure_mirror_maker

#copy the keystore that was specified over to the local kafka copy with a generic name
cp -vf $keystore_file $PWD/kafka/config/keystore.jks
#specify the generic name for the container kafka location
sed -i "s?ssl.truststore.location=.*?ssl.truststore.location=/kafka/config/keystore.jks?g" $mm_consumer_config_file

docker build $no_cache -t="mycompany/kafka" .

if [ `docker images -q -f dangling=true| wc -l` -gt 0 ]; then #clean up dangling images if they exist
  docker rmi $(docker images -q -f dangling=true)
fi
