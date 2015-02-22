#!/bin/bash

# Check for full domain
if [[ $1 != -* ]] && [[ $1 == *.* ]]; then
	__app=${1%%.*}
	__domain=${1#*.}
	shift
fi

