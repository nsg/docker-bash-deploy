#!/bin/bash

save_metadata() {
	local domain=$1
	local app=$2
	local key=$3
	local value=$4

	mkdir -p /tmp/docker/$domain/$app
	if [ "x$value" == "xfalse" ]; then
		rm /tmp/docker/$domain/$app/$key
	else
		echo $value > /tmp/docker/$domain/$app/$key
	fi
}

get_metadata() {
	local domain=$1
	local app=$2
	local key=$3

	[ -f /tmp/docker/$domain/$app/$key ] && cat /tmp/docker/$domain/$app/$key
}

has_metadata() {
	local domain=$1
	local app=$2
	local key=$3

	[ -f /tmp/docker/$domain/$app/$key ] && return 0
	return 1
}

