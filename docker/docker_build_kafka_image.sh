#!/bin/sh
. ../scripts/build_kafka_configuration.sh

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

mm_consumer_config_template_file="../scripts/config/$kafka_version/mm_consumer-template.properties"
mm_producer_config_template_file="../scripts/config/$kafka_version/mm_producer-template.properties"
mm_consumer_config_file="$PWD/kafka/config/mm_consumer.properties"
mm_producer_config_file="$PWD/kafka/config/mm_producer.properties"

cp -vf $mm_consumer_config_template_file $mm_consumer_config_file
cp -vf $mm_producer_config_template_file $mm_producer_config_file

configure_mirror_maker

keystore_file='hospitality-streaming-pr.travelport.com.keystore.jks'
cp -vf ../scripts/$keystore_file $PWD/kafka/config
sed -i "s/#ssl.truststore.location=*/ssl.truststore.location=config/$keystore_file/g" $mm_consumer_config_file

docker build $no_cache -t="mycompany/kafka" .

docker rmi $(docker images -q -f dangling=true)
