#!/bin/bash

# Global flags
while getopts "hDc:i:H:sk:v:a:o:" opt; do
	case $opt in
		h)
			show_help
			;;
		D)
			__debug=true
			;;
		c)
			__config="$OPTARG"
			;;
		i)
			__image="$OPTARG"
			;;
		H)
			__host="$OPTARG"
			;;
		s)
			__servers=true
			;;
		k)
			__key="$OPTARG"
			;;
		v)
			__value="$OPTARG"
			;;
		a)
			__app="$OPTARG"
			;;
		o)
			__domain="$OPTARG"
			;;
	esac
done

