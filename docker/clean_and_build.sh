#!/bin/sh
. ../scripts/common.sh

downloadable="kafka_$scala_version-$kafka_version.tgz"
download_url="http://www-us.apache.org/dist/kafka/$kafka_version/$downloadable"
display_info "downloading $download_url..."
kafka_base_location="$PWD/kafka"
mkdir -pv $kafka_base_location

curl -O $download_url \
&& tar -xvf $downloadable -C $kafka_base_location \
&& rm -f $downloadable
