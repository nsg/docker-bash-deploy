#!/bin/bash

setup_host() {
	check_release

	export DEBIAN_FRONTEND=noninteractive

	# Setup docker repo
	apt-key adv \
		--keyserver hkp://keyserver.ubuntu.com:80 \
		--recv-keys 36A1D7869245C8950F966E92D8576A8BA88D21E9
	echo deb https://get.docker.com/ubuntu docker main > /etc/apt/sources.list.d/docker.list

	# Setup gluster repo
	wget -O /tmp/glusterfs.key \
		http://download.gluster.org/pub/gluster/glusterfs/3.6/LATEST/Debian/wheezy/pubkey.gpg
	echo "d903892dfe9afa0be141f27fd1c1889f770b4e8d  /tmp/glusterfs.key" | sha1sum -c - || exit 1
		apt-key add /tmp/glusterfs.key
	    echo "deb [arch=amd64] http://download.gluster.org/pub/gluster/glusterfs/3.6/3.6.1/Debian/wheezy/apt wheezy main" > /etc/apt/sources.list.d/glusterfs.list

	# Update repos
	apt-get update

	# Install packages
	apt-get install -y lxc-docker nginx glusterfs-server attr iptables-persistent

	# nginx config
	rm -f /etc/nginx/sites-available/* /etc/nginx/sites-enabled/*
	open_port tcp 80

	# Detect default interface for ipv4 and ipv6
	local ifv4=$(ip -4 route get 8.8.8.8 | grep dev | sed 's/.*dev \([^ ]*\).*/\1/')
	local ifv6=$(ip -6 route get 2001:4860:4860::8888 | grep dev | sed 's/.*dev \([^ ]*\).*/\1/')

	if [ -z $ifv4 ] && [ -z $ifv6 ]; then
		echo "Error, no IPv4 or IPv6 interfaces found."
		echo "Install aborted"
		exit 1
	fi

	# Configure firewall for IPv4
	if [[ $ifv4 != lo ]] && [ ! -z $ifv4 ]; then
		echo "Host has IPv4: Default IPv4 interface is $ifv4"

		# Drop all packages from the internet
		firewall_rule 4 -P INPUT   DROP
		firewall_rule 4 -P FORWARD DROP
		firewall_rule 4 -P OUTPUT  ACCEPT

		# Allow traffic on local if
		firewall_rule 4 -A INPUT  -i lo -j ACCEPT
		firewall_rule 4 -A OUTPUT -o lo -j ACCEPT

		# Allow traffic on other networks
		firewall_rule 4 -A INPUT  ! -i $ifv4 -j ACCEPT

		# Accept
		firewall_rule 4 -A INPUT -i $ifv4 -m state --state ESTABLISHED,RELATED -j ACCEPT
		firewall_rule 4 -A INPUT -i $ifv4 -p icmp -m limit --limit 10/second -j ACCEPT

		# Limit SSH access
		firewall_rule 4 -A INPUT -p tcp --dport 22 -m recent --update --seconds 60 \
			--hitcount 15 --name SSH -j DROP
		firewall_rule 4 -A INPUT -p tcp --dport 22 -m state --state NEW -m recent \
			--set --name SSH -j ACCEPT
	fi

	# Configure firewall for IPv6
	if [[ $ifv6 != lo ]] && [ ! -z $ifv6 ]; then
		echo "Host has IPv6: Default IPv6 interface is $ifv6"

		# Drop all packages from the internet
		firewall_rule 6 -P INPUT   DROP
		firewall_rule 6 -P FORWARD DROP
		firewall_rule 6 -P OUTPUT  ACCEPT

		# Allow traffic on local if
		firewall_rule 6 -A INPUT  -i lo -j ACCEPT
		firewall_rule 6 -A OUTPUT -o lo -j ACCEPT

		# Allow traffic on other networks
		firewall_rule 4 -A INPUT  ! -i $ifv6 -j ACCEPT

		# Accept
		firewall_rule 6 -A INPUT -i $ifv6 -m state --state ESTABLISHED,RELATED -j ACCEPT
		firewall_rule 6 -A INPUT -i $ifv6 -p icmp -m limit --limit 10/second -j ACCEPT

		# Limit SSH access
		firewall_rule 6 -A INPUT -p tcp --dport 22 -m recent --update --seconds 60 \
			--hitcount 15 --name SSH -j DROP
		firewall_rule 6 -A INPUT -p tcp --dport 22 -m state --state NEW -m recent \
			--set --name SSH -j ACCEPT
	fi

	save_firewall

	# Download docker-gc from Spotify
	if [ ! -f /etc/cron.hourly/docker-gc ]; then
		echo "Download docker-gc from Spotify"
		curl -L https://raw.githubusercontent.com/spotify/docker-gc/1b5d533172fa3707dcd4e5a4a3b7cd25d6e6e237/docker-gc -o /tmp/docker-gc
		echo "512be3310ab699b9ff414bc4026553a32eab31af  /tmp/docker-gc" | sha1sum -c - || exit 1
		mv /tmp/docker-gc /etc/cron.hourly/docker-gc
		chmod +x /etc/cron.hourly/docker-gc
	fi

}

setup_gluster_share() {
	local num_vpn_nodes=1
	local bricks=

	# Use the ARP table to detect the other hosts.
	for ip in $(arp -an -H ether | awk '/on vpn/{print $2}' | tr -d '()'); do
		num_vpn_nodes=$(( $num_vpn_nodes + 1 ))
		bricks="$bricks $ip:/share"
		if ! gluster peer status | awk '/Hostname/{print $NF}' | grep -q $ip; then
			echo "Add Gluster peer $ip"
			gluster peer probe $ip
		fi
	done

	# Make sure we have the shared path
	mkdir -p /share

	for ip in $(hostname -I); do
		if [[ $ip == '10.10.0.1' ]]; then
			bricks="$ip:/share $bricks"
			local num_bricks=$(gluster volume info share | awk '/Number of Bricks/{print $NF}')
			echo "This is VPN host 10.10.0.1, we have $num_vpn_nodes bricks in the cluster."
			if [[ $num_bricks != $num_vpn_nodes ]]; then

				# Bricks do not match VPN nodes, try to change that
				if [ $num_vpn_nodes -gt $num_bricks ]; then
					echo "Number of bricks/replica need to be increased to $num_vpn_nodes"
					echo gluster volume add-brick share replica $num_vpn_nodes 
				else
					echo "We need to decrease number of bricks to $num_vpn_nodes"
					echo "NOT implemented"
					exit 1
				fi

#				gluster volume create share replica $num_vpn_nodes \
#					transport tcp $bricks force
#				gluster volume start share


			fi
		fi
	done
}

check_release() {
	local version=$(lsb_release -rs)

	# Make sure this is a supported version
	case $version in
		14.04)
			echo "Detected Ubuntu $version LTS, supported!"
			;;
		*)
			echo "Detected $version, not supported."
			echo "Aborted!"
			exit 1
			;;
	esac
}

