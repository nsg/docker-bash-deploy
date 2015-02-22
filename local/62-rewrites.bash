#!/bin/bash

# Check for full domain
if [[ $1 != -* ]] && [[ $1 == *.* ]]; then
	__app=${1%%.*}
	__domain=${1#*.}
	echo -e "\e[1mSet -a $__app -o $__domain\e[0m"
	shift
fi

