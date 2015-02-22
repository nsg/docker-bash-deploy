#!/bin/bash

[ $__debug ] && echo "debug mode: true"

# Load config
if [ $__config ]; then
	load_config $__config
elif [ -f ~/.docker-bash-deploy ]; then
	load_config ~/.docker-bash-deploy
else
	echo "No hosts loaded, abort!" 2>&1
	exit 1
fi

[ $__host   ] && hosts=$__host
[ $__domain ] && domain=$__domain
[ $__debug  ] && echo "hosts: $hosts"
[ $__debug  ] && echo "domain: $domain"
