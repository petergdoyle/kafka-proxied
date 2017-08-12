#!/bin/sh

groupid='kafka'
version='1.0.0-SNAPSHOT'
packaging='jar'

for each in `find kafka.git -name '*SNAPSHOT.jar'`; do
  filename=$(basename "$each")
  extension="${filename##*.}"
  artifact_id="${filename%-1.0.0-SNAPSHOT.*}"
  cmd="mvn install:install-file -Dfile=$each -DgroupId=$groupid -DartifactId=$artifact_id -Dversion=$version -Dpackaging=$packaging"
  echo "$cmd"
  # sleep 1
  # eval "$cmd"
done

# mvn install:install-file -Dfile=<path-to-file>
