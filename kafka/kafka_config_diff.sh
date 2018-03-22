#!/bin/bash
. ../common.sh

v1='0.10.1.1'
v2='0.10.2.1'
for each in `find config/$v1 -type f| sed "s/.*\///"`; do
  if [ -f config/$v2/$each ]; then
    echo -e "\n\n*** compare config/$v1/$each -> config/$v2/$each ***\n"
    diff -qy --suppress-common-lines config/$v1/$each config/$v2/$each
  else
    display_warn "config/$v2/$each does not exist"
  fi
done
