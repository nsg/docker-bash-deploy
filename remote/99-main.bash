#!/bin/bash

# This is the top of the remote part of the script called 'deploy'.

GIT_VERSION=HEAD

shopt -s nullglob

# Version check
if [ "x$1" != "x$GIT_VERSION" ]; then
	echo "Error : Version mismatch"
	echo "Local : $1"
	echo "Remote: $GIT_VERSION"
	echo "Aborted, upgrade the remote version with 'install remote'"
	exit 1
fi

shift

case $1 in
	deploy)
		deploy_container $2 $3 $4 $5
		;;
	undeploy)
		undeploy_container $2 $3
		;;
	remove)
		remove_app $2 $3
		;;
	setup)
		setup_host
		;;
	list)
		list_apps
		;;
	save-metadata)
		save_metadata $2 $3 $4 $5
		;;
	get-metadata)
		get_metadata $2 $3 $4
		;;
	status)
		show_status $2
		;;
	openport)
		open_port $2 $3
		;;
	waitfor)
		while true; do sleep 1; done
		;;
	version)
		echo $GIT_VERSION
		;;
esac
