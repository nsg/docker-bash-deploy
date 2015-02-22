#!/bin/bash

# List running containers
if [ $__list ]; then
	for host in $hosts; do
		echo -e "\e[1m$host\e[0m:"
		remote_command $host list
		echo
	done
fi
