#!/bin/bash

if [ $__show_config ]; then
	echo "Loaded config file:"
	if [ $__config ]; then
		cat $__config
	else
		cat ~/.docker-bash-deploy
	fi
	echo
	echo "Set config to:"
	echo "servers=$hosts"
	echo "domain=$domain"
fi
