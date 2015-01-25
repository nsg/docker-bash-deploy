#!/bin/bash

REMOTE_DEPLOY_COMMAND=out/remote-deploy
GIT_VERSION=HEAD

TINC_CLUSTER_URL=https://raw.githubusercontent.com/nsg/tinc-cluster/master/setup-vpn
TINC_LOCAL_FILE=/tmp/setup-vpn
TINC_SHA1SUM=382f44ff9c68d76e8670fbfb0a4bf2c5a1ce5f9f

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
if [ $__host ]; then
	hosts=$__host
fi
if [ $__domain ]; then
	domain=$__domain
fi
[ $__debug ] && echo "hosts: $hosts"
[ $__debug ] && echo "domain: $domain"

# Download and verify setup-vpn from GitHub
wget_sha1sum $TINC_CLUSTER_URL $TINC_LOCAL_FILE $TINC_SHA1SUM

# Setup connections (if needed)
for host in $hosts; do
	if ! ps -ef | grep ssh | grep $host | grep -q waitfor; then
		echo "Setup persistent connection to $host"
		remote_command $host waitfor &
	fi
done

# Show config
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

# List running containers
if [ $__list ]; then
	for host in $hosts; do
		echo -e "\e[1m$host\e[0m:"
		remote_command $host list
		echo
	done
fi

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

# List server status
if [ $__servers ]; then
	for host in $hosts; do
		echo -en "\e[1m$host\e[0m: "
		remote_command_raw $host lsb_release -ris | tr '\n' ' '
		echo -n "⇨ $(remote_command_raw $host docker -v) " \
			"containers: $(remote_command_raw $host docker ps -q 2> /dev/null | wc -l)"
		echo
		remote_command $host list
		echo
	done
fi

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

# Show status
if [ $__status ]; then
	for host in $hosts; do
		echo -e "\e[1m$host\e[0m: "
		remote_command $host status $__status
	done
fi
