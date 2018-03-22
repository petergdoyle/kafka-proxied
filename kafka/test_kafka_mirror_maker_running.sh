#!/bin/bash
cd $(dirname $0)
. ./kafka_common.sh

check_mirror_maker_status
