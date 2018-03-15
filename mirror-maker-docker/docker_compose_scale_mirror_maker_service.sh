#!/bin/bash

scale=`docker-compose ps|  sed 1,2d| grep kafka-mirror-maker-service| wc -l`
service="kafka-mirror-maker-service"
read -e -p "Enter the scale factor for $service: " -i "$scale" scale

docker-compose scale kafka-mirror-maker-service=$scale
