#!/bin/sh

git clone --depth 1 https://github.com/apache/kafka.git
cd kafka/

gradle -version > /dev/null 2>&1
if [ $? -eq 127 ]; then
  ./install_gradle.sh
fi
gradle
./gradlew jar

cd -
