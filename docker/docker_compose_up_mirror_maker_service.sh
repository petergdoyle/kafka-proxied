#!/bin/sh

scale='3'
service="kafka-mirror-maker-service"
read -e -p "Enter the scale factor for $service: " -i "$scale" scale

docker-compose scale $service=$scale
