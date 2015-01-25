#!/bin/bash

list_apps() {
	has_apps || exit 0

	declare -a containers

	for uid in $(docker ps --no-trunc -q); do
		local domain_app=$(get_domain_app_from_id $uid)

		local domain=$(echo $domain_app | awk '{print $1}')
		local app=$(echo $domain_app | awk '{print $2}')
		local port=$(get_metadata $domain $app port)
		local image=$(get_metadata $domain $app image)
		local default=$(get_metadata $domain $app default)
		local http_port=80;
		if has_metadata $domain $app http-port; then
			http_port=$(get_metadata $domain $app http-port)
		fi

		containers+=($app.$domain)

		echo -n "$app.$domain ($image):$http_port ⇄ $port"

		# Is this the default container
		if [ $default ]; then
			echo -n " [default]"
		fi

		# DNS lookup
		check_for_dns $domain $app

		echo # newline

		for p in /tmp/docker/$domain/$app/port[0-9]*; do
			if [ -f $p ]; then
				local p1=$(basename $p)
				local p2=$(cat $p)
				echo -e " ↳ forwarded port ${p1:4} ⇄ $p2"
			fi
		done

	done

	for domain in /tmp/docker/*; do
		for app in $domain/*; do
			local atest=${app##*/}.${domain##*/}
			if ! array_has_element $atest "${containers[@]}"; then
				echo -n "$atest [not deployed]"
		
				# DNS lookup
				check_for_dns ${domain##*/} ${app##*/}

				echo # newline
			fi
		done
	done

}

