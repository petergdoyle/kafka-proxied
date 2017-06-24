#!/usr/bin/env bash


if [ -z ${KAFKA_HOME+x} ]; then
  read -e -p "Kafka does not appear to be installed. Install Kafka locally? " -i "y" response
  if [ "$response" != 'y' ]; then
   echo "Cannot continue"
   exit 1
  fi
else
  read -e -p "Kafka already appears to be installed. Install Kafka anyway? " -i "y" response
  if [ "$response" != 'y' ]; then
   echo "Cannot continue"
   exit 1
  fi
fi

kafka_version="0.10.0.1"
scala_version="2.11"
read -e -p "Confirm Kafka version: " -i "$kafka_version" kafka_version
read -e -p "Confirm Scala version: " -i "$scala_version" scala_version

kafka_base_location="$PWD/../local"
read -e -p "Specify Kafka installation location: " -i "$kafka_base_location" kafka_base_location

install_anyway="y"
if [ -d $kafka_base_location/kafka_$scala_version-$kafka_version ]; then
 read -e -p "It appears kafka is already installed at $kafka_base_location/kafka_$scala_version-$kafka_version. Install again (y/n)? " -i "$install_anyway" install_anyway
fi

if [ "$install_anyway" == "y" ]; then

  if [ ! -d "$kafka_base_location" ]; then
   mkdir -p $kafka_base_location
  fi

  downloadable="kafka_$scala_version-$kafka_version.tgz"
  download_url="http://www-us.apache.org/dist/kafka/$kafka_version/$downloadable"
  echo "downloading $download_url..."
  kafka_home="$kafka_base_location/default"

  curl -O $download_url \
  && tar -xvf $downloadable -C $kafka_base_location \
  && rm -f $downloadable \
  && ln -s $kafka_base_location/kafka_$scala_version-$kafka_version $kafka_home

  if `grep KAFKA_HOME ~/.bash_profile` ; then
    # replace
    sed -i "s/export KAFKA_HOME=.*/export KAFKA_HOME=$kafka_home/g" ~/.bash_profile
  else
    # insert
   export KAFKA_HOME=$kafka_base_location/default
      cat >>~/.bash_profile <<-EOF
export KAFKA_HOME=$KAFKA_HOME
EOF
  fi

   mkdir -p $kafka_base_location/logs \
   && chmod 1777 $kafka_base_location/logs

   echo -e "\e[7;44;96m*$kafka_version is now installed at $kafka_base_location/default. Log out and log back in to set the proper envariable. \e[0m"

fi

else
   echo -e "\e[7;44;96m*Kafka appears to be installed at $KAFKA_HOME. \e[0m"
