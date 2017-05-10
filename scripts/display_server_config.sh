#!/bin/sh

node=`hostname |grep -io node[0-9] |awk '{print tolower($0)}'`
grep -v "^#" config/server-$node.properties|awk 'NF'
