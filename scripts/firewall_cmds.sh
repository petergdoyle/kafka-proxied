#!/bin/sh

function firewall_on () {
firewall-cmd --zone=public --add-port=12181/tcp
firewall-cmd --zone=public --add-port=19091/tcp
firewall-cmd --zone=public --add-port=19092/tcp
}

function firewall_off () {
firewall-cmd --zone=public --remove-port=12181/tcp
firewall-cmd --zone=public --remove-port=19091/tcp
firewall-cmd --zone=public --remove-port=19092/tcp
}
