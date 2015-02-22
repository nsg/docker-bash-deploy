#!/bin/bash

# Set metadata
if [ $__metadata ] && [ $__app ] && [ $__key ] && [ $__value ] && [ $domain ]; then
	for host in $hosts; do
		echo "set $__app.$domain: $__key=$__value at $host"
		save_metadata $host $domain $__app $__key $__value
	done
elif [ $__metadata ] && [ $__app ] && [ $domain ]; then
	for host in $hosts; do
		get_app $host $domain $__app
	done
fi
