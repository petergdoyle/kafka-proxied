
    # install kafka on all nodes
    kafka_version='kafka_2.11-0.9.0.1'
    kafka_base_location="$PWD/local"
    if [ ! -d "$kafka_base_location/$kafka_version" ]; then
      mkdir -p $kafka_base_location \
      && echo "downloading $kafka_version..."

      curl -O http://www-us.apache.org/dist/kafka/0.9.0.1/kafka_2.11-0.9.0.1.tgz \
      && tar -xvf kafka_2.11-0.9.0.1.tgz -C $kafka_base_location \
      && rm -f kafka_2.11-0.9.0.1.tgz \
      && ln -s $kafka_base_location/kafka_2.11-0.9.0.1 $kafka_base_location/default

      export KAFKA_HOME=$kafka_base_location/default
#       cat >/etc/profile.d/kafka.sh <<-EOF
# export KAFKA_HOME=$KAFKA_HOME
# EOF
      mkdir -p $kafka_base_location/logs \
      && chmod 1777 $kafka_base_location/logs

    else
      echo -e "\e[7;44;96m*$kafka_version already appears to be installed. skipping.\e[0m"
    fi
