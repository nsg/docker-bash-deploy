#!/bin/bash

# List server status
if [ $__servers ]; then
	for host in $hosts; do
		echo -en "\e[1m$host\e[0m: "
		remote_command_raw $host lsb_release -ris | tr '\n' ' '
		echo -n "⇨ $(remote_command_raw $host docker -v) " \
			"containers: $(remote_command_raw $host docker ps -q 2> /dev/null | wc -l)"
		echo
		remote_command $host list
		echo
	done
fi
