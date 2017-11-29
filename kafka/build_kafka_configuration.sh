#!/bin/sh
. /kafka_common.sh

if [ -z $KAFKA_HOME ]; then
  display_error "No env var KAFKA_HOME is set. Source your ~/.bash_profile or logout and log back in"
  exit 1
fi
