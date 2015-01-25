#!/bin/bash

save_firewall() {
	iptables-save > /etc/iptables/rules.v4
	ip6tables-save > /etc/iptables/rules.v6
}

firewall_rule() {
	local version=$1
	local flag=$2
	shift 2
	if [[ $version == 4 ]]; then
		iptables  -C $@ 2> /dev/null || ( 
			[[ $flag != -P ]] && set -x
			iptables  $flag $@
		)
	else
		ip6tables -C $@ 2> /dev/null || (
			[[ $flag != -P ]] && set -x
			ip6tables $flag $@
		)
	fi
}

remove_port_rule() {
	local proto=$1
	local port=$2

	if has_ipv4; then
		local host4=$(ip -4 route get 8.8.8.8 | awk '/src/{print $NF}')
		while iptables -D INPUT -p $proto --dport $port -d $host4 -j DROP 2> /dev/null; do
			echo "Remove INPUT FW rule for $proto:$port for ipv4"
		done
		while iptables -D FORWARD -p $proto --dport $port -d $host4 -j DROP 2> /dev/null; do
			echo "Remove FORWARD FW rule for $proto:$port for ipv4"
		done
	fi

	if has_ipv6; then
		local host6=$(ip -6 route get 2001:4860:4860::8888 | awk '/src/{print $NF}')
		while ip6tables -D INPUT -p $proto --dport $port -d $host6 -j DROP 2> /dev/null; do
			echo "Remove INPUT FW rule for $proto:$port for ipv6"
		done
		while ip6tables -D FORWARD -p $proto --dport $port -d $host6 -j DROP 2> /dev/null; do
			echo "Remove FORWARD FW rule for $proto:$port for ipv6"
		done
	fi

	save_firewall
}

open_port() {
	local proto=$1
	local port=$2

	if has_ipv4; then
		local ifv4=$(ip -4 route get 8.8.8.8 | grep dev | sed 's/.*dev \([^ ]*\).*/\1/')
		firewall_rule 4 -I INPUT -p $proto --dport $port -i $ifv4 -j ACCEPT
	fi

	if has_ipv6; then
		local ifv6=$(ip -6 route get 2001:4860:4860::8888 | grep dev | sed 's/.*dev \([^ ]*\).*/\1/')
		firewall_rule 6 -I INPUT -p $proto --dport $port -i $ifv6 -j ACCEPT
	fi

	save_firewall
}

