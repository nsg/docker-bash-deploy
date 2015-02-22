#!/bin/bash

# Deploy a container
if [ $__deploy ] && [ $__app ] && [ $__image ] && [ $domain ]; then
	for host in $hosts; do
		echo -e "\e[1m$host\e[0m: "
		remote_command $host deploy $domain $__app $__image
	done
fi

# Undeploy a container
if [ $__undeploy ] && [ $__app ] && [ $domain ]; then
	for host in $hosts; do
		echo -e "\e[1m$host\e[0m: "
		remote_command $host undeploy $domain $__app
	done
fi

# Remove a container
if [ $__remove ] && [ $__app ] && [ $domain ]; then
	for host in $hosts; do
		echo -e "\e[1m$host\e[0m: "
		remote_command $host remove $domain $__app
	done
fi
