#!/bin/bash

has_app() {
	local domain=$1
	local chapp=$2

	for uid in $(docker ps --no-trunc -q); do
		local app=$(get_app_from_id_with_domain $domain $uid)
		if [ x$app == x$chapp ]; then
			echo yes
			return;
		fi
	done
}

get_app_from_id_with_domain() {
	local domain=$1
	local uid=$2

	local path=$(echo /tmp/docker/$domain/*/id)
	[ ! -z $path ] && grep -l $uid $path | awk -F'/' '{print $5}'
}

get_domain_app_from_id() {
	local uid=$1

	local path=$(grep -l $uid /tmp/docker/*/*/id)
	path=${path%/id}

	echo $(cat $path/domain) $(cat $path/app)
}

find_free_port() {
	for port in $(seq 30000 39999); do
		if ! netstat -nta | grep -q $port; then
			echo $port;
			break;
		fi;
	done
}

app_in_dns() {
	local app=$1
	local domain=$2

	for record in A AAAA; do
		for ip in $(dig +short $record $app.$domain); do
			if ip addr | grep -qi $ip; then
				echo true
				return
			fi
		done
	done
}

has_ipv4() {
	if ip -4 route get 8.8.8.8 | grep -q unreachable; then
		return 1
	fi
	return 0
}

has_ipv6() {
	if ip -6 route get 2001:4860:4860::8888 | grep -q unreachable; then
		return 1
	fi
	return 0
}

array_has_element() {
	local elem
	for elem in "${@:2}"; do
		if [ "x$elem" == "x$1" ]; then
			return 0
		fi
	done
	return 1
}

check_for_dns() {
	local domain=$1
	local app=$2

	for record in A AAAA; do
		for ip in $(dig +short $record $app.$domain); do
			if ip addr | grep -qi $ip; then
				echo -n " [DNS:$record]"
			fi
		done
	done
}

has_apps() {
	for f in /tmp/docker/*; do
		[ -d $f ] && return 0
	done
	return 1
}

