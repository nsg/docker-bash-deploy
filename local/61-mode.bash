#!/bin/bash

# Select mode
case $1 in
	config)
		__show_config=true
		[ -z $2 ] && show_help $1
		shift 2
		;;
	list)
		__list=true
		shift
		;;
	install)
		__install=$2
		[ -z $2 ] && show_help $1
		shift 2
		;;
	deploy)
		__deploy=true
		[ -z $2 ] && show_help $1
		shift
		;;
	undeploy)
		__undeploy=true
		[ -z $2 ] && show_help $1
		shift
		;;
	meta)
		__metadata=true
		[ -z $2 ] && show_help $1
		shift
		;;
	remove)
		__remove=true
		[ -z $2 ] && show_help $1
		shift
		;;
	status)
		__status=$2
		[ -z $2 ] && show_help $1
		shift
		;;
	*)
		show_help
		;;
esac

