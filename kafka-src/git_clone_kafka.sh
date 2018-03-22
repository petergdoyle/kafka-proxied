#!/bin/bash

kafka_git_url="https://github.com/apache/kafka.git"
target_dir="kafka.git"
if [ -d $target_dir ]; then
  response="y"
  read -e -p "Kafka already appears to be cloned locally. Do you want to run a git pull (y/n)? " -i "$response" response
  if [ "$response" != "y" ]; then
    response="y"
    read -e -p "Do you want to delete the local copy and clone again (y/n)? " -i "$response" response
    if [ "$response" != "y" ]; then
      exit 0
    else
      echo -e "removing local kafka clone..."
      rm -frv $target_dir
      echo -e "cloning kafka repository from $kafka_git_url..."
      git clone --depth 1 $kafka_git_url $target_dir
      cd $target_dir
    fi
  else
    cd $target_dir
    echo -e "pulling latest from kafka repository..."
    git pull
  fi
else
  echo -e "cloning kafka repository from $kafka_git_url..."
  git clone --depth 1 $kafka_git_url $target_dir
  cd $target_dir
fi

gradle -version > /dev/null 2>&1
if [ $? -eq 127 ]; then
  ./install_gradle.sh
fi
gradle
./gradlew jar

cd -
