#!/bin/sh

mvn -f $PWD/springboot-pom.xml clean install &&
java -jar target/HttpKafkaAdapter-1.0-SNAPSHOT.jar
