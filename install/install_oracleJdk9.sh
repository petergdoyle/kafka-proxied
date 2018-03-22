#!/bin/bash
. ../common.sh

BASE_URL_9=http://download.oracle.com/otn-pub/java/jdk/9.0.1+11/jdk-9.0.1_
declare -a PLATFORMS=("linux-x64_bin.tar.gz")

for platform in "${PLATFORMS[@]}"; do
  curl -C - -LR#OH "Cookie: oraclelicense=accept-securebackup-cookie" -k "${BASE_URL_9}${platform}"
done
