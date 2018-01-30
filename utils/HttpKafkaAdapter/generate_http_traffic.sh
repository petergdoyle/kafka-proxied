#!/bin/sh
. ../../common.sh

data=$data_dir/MOCK_DATA.json

while read p; do
  cmd="curl -i -X POST -H \"Content-Type: application/json\" -d '$p' http://localhost:8080/HttpKafkaAdapterServlet/"
  echo 'sending message '$p
  eval $cmd
  sleep 1
done < $data
