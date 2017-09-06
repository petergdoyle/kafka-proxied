#!/bin/sh
. ./common.sh

cp -vf Dockerfile.template Dockerfile

downloadable="kafka_$scala_version-$kafka_version.tgz"
download_url="http://www-us.apache.org/dist/kafka/$kafka_version/$downloadable"
kafka_installation_dir="/usr/kafka/kafka_$scala_version-$kafka_version"

sed -i "s%DOWNLOAD_URL%$download_url%g" Dockerfile
sed -i "s%KAFKA_INSTALLATION_DIR%$kafka_installation_dir%g" Dockerfile
sed -i "s%DOWNLOADABLE%$downloadable%g" Dockerfile

docker build --no-cache -t="mycompany/kafka" .
