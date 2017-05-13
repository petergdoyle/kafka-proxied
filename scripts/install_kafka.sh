#!/usr/bin/env bash


if [ -z ${KAFKA_HOME+x} ]; then
   read -e -p "Kafka does not appear to be installed. Install Kafka locally?" -i "y" response
   if [ "$response" != 'y' ]; then
     echo "Cannot continue"
     exit 1
   fi
 else
   exit 0
 fi

 kafka_version="10.0.1"
 scala_version="2.11"
 read -e -p "Confirm Kafka version: " -i "$kafka_version" kafka_version

 kafka_base_location="$PWD/local"
 read -e -p "Specify Kafka installation location: " -i "$kafka_base_location" kafka_base_location

 if [ ! -d "$kafka_base_location" ]; then
   mkdir -p $kafka_base_location \
   && echo "downloading $kafka_version..."

   curl -O http://www-us.apache.org/dist/kafka/$kafka_version/kafka_$scala_version-$kafka_location.tgz \
   && tar -xvf kafka_$scala_version-$kafka_version.tgz -C $kafka_base_location \
   && rm -f kafka_$scala_version-$kafka_version.tgz \
   && ln -s $kafka_base_location/kafka_$scala_version-$kafka_version $kafka_base_location/default

   export KAFKA_HOME=$kafka_base_location/default
      cat >~/.bash_profile <<-EOF
export KAFKA_HOME=$KAFKA_HOME
EOF
   mkdir -p $kafka_base_location/logs \
   && chmod 1777 $kafka_base_location/logs

   echo -e "\e[7;44;96m*$kafka_version is now installed at $kafka_base_location/default. Log out and log back in to set the proper envariable. \e[0m"

 else
   echo -e "\e[7;44;96m*$kafka_version already appears to be installed. skipping.\e[0m"
 fi
