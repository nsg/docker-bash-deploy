#!/bin/bash

# Show status
if [ $__status ]; then
	for host in $hosts; do
		echo -e "\e[1m$host\e[0m: "
		remote_command $host status $__status
	done
fi
