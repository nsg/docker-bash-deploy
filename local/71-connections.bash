#!/bin/bash

# Setup connections (if needed)
for host in $hosts; do
	if ! ps -ef | grep ssh | grep $host | grep -q waitfor; then
		echo "Setup persistent connection to $host"
		remote_command $host waitfor &
	fi
done
