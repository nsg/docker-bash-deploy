#!/bin/bash

show_status() {
	local ch=$1

	if [[ $ch == "fs" ]]; then
		echo -e "\n\e[4mGluster peers\e[0m"
		gluster peer status | cat -
		echo
		echo -e "\n\e[4mGluster volumes\e[0m"
		gluster volume status | cat -
		echo
		echo -e "\e[4mContainer disk usage\e[0m"
		df -h /var/lib/docker/ --output="ipcent,pcent" | \
			tail -1 | awk '{ print "inodes "$1" bytes "$2 }'
	elif [[ $ch == "vpn" ]]; then
		echo -e "\n\e[4mVPN device statics\e[0m"
		ip addr show dev vpn

		echo -e "\e[4mVPN status\e[0m"
		local pid=$(pgrep tincd)
		kill -USR2 $pid
		kill -USR1 $pid
		grep $(date +%H:%M) /var/log/syslog \
			| grep "vpn\[$pid\]" \
			| sed "s/.*tinc\.vpn\[$pid\]: //"
	fi
}
