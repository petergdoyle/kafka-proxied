#!/bin/sh

mkdir kafka-sources
mkdir kafka-binaries

for each in `find kafka/ -name '*-1.0.0-SNAPSHOT.jar'`; do
  cp -v $each kafka-binaries
done

for each in `find kafka/ -name '*-1.0.0-SNAPSHOT-sources.jar'`; do
  cp -v $each kafka-sources
done
