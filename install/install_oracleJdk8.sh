#!/bin/sh

## Latest JDK8 version is JDK8u151 released on 17th Oct, 2017.
BASE_URL_8=http://download.oracle.com/otn-pub/java/jdk/8u151-b12/e758a0de34e24606bca991d704f6dcbf/jdk-8u151

JDK_VERSION=`echo $BASE_URL_8 | rev | cut -d "/" -f1 | rev`

declare -a PLATFORMS=("-linux-x64.tar.gz")

for platform in "${PLATFORMS[@]}"
do
    wget -c --header "Cookie: oraclelicense=accept-securebackup-cookie" "${BASE_URL_8}${platform}"
done
