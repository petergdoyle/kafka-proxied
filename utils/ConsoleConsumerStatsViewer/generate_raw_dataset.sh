#!/bin/sh


range_lo='0'
read -e -p "Enter message id range lo: " -i "$range_lo" range_lo
range_hi='99'
read -e -p "Enter message id range hi: " -i "$range_hi" range_hi


for i in $(eval echo "{$range_lo..$range_hi}"); do echo $i; done > messages
