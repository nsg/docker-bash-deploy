#!/bin/bash

# Install the remote half of the script
if [ $__install ]; then
	for host in $hosts; do
		echo -e "\e[1m$host\e[0m:"
		if [ "x$__install" == "xfull" ] || [ "x$__install" == "xremote" ]; then
			[[ $GIT_VERSION == HEAD ]] && make merge
			scp $REMOTE_DEPLOY_COMMAND root@$host:/usr/local/bin/deploy
			ssh root@$host chmod +x /usr/local/bin/deploy
		fi

		if [ "x$__install" == "xfull" ]; then
			remote_command $host setup
		fi
	done

	if [ "x$__install" == "xfull" ] || [ "x$__install" == "xvpn" ]; then
		chmod +x $TINC_LOCAL_FILE
		for host in $hosts; do
			remote_command $host openport tcp 655
		done
		echo $hosts | $TINC_LOCAL_FILE vpn
	fi
fi
