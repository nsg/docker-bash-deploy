#!/bin/bash

load_config() {
	local file=$1

	if [ ! -f $file ]; then
		echo "Config file '$file' not found" 2>&1
		exit 1
	fi

	hosts="$(awk -F'=' '/servers/{print $NF}' $file)"
	domain="$(awk -F'=' '/domain/{print $NF}' $file)"
}

get_app() {
	local host=$1
	local domain=$2
	local app=$3

	echo -e "\e[1m$host\e[0m:"
	remote_command_raw $host "
		for f in /tmp/docker/$domain/$app/*; do
			[ -f \$f ] && (echo -n \"\${f##*/} ↠ \"; cat \$f)
		done"
	echo
}

remote_command() {
	local host=$1
	shift
	ssh \
		-l root \
		-o ControlPath=/tmp/shdeploy-%l-%r@%h:%p \
		-o ControlMaster=auto \
		$host deploy $GIT_VERSION $@ \
		| grep -v 'disabling multiplexing'
}

remote_command_raw() {
	local host=$1
	shift
	ssh \
		-l root \
		-o ControlPath=/tmp/shdeploy-%l-%r@%h:%p \
		-o ControlMaster=auto \
		$host $@ \
		| grep -v 'disabling multiplexing'
}

save_metadata() {
	local host=$1
	local domain=$2
	local app=$3
	local key=$4
	local value=$5

	remote_command $host save-metadata $domain $app $key $value
}

wget_sha1sum() {
	if [ ! -f $2 ]; then
		echo "Download $1 to $2"
		wget -qO $2 $1
	fi
	echo "$3  $2" | sha1sum -c - > /dev/null
	if [ $? != 0 ]; then
		echo "Checksum error! $2 is not $3";
		echo "Try to remove $2 and try again."
		exit 1
	fi
}

