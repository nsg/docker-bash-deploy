#!/bin/bash

deploy_container() {
	local domain=$1
	local app=$2
	local image=$3
	local port=$(find_free_port)

	[[ $image == - ]] && image=$(get_metadata $domain $app image)

	if [ "x$(app_in_dns $app $domain)" == xtrue ]; then
		mkdir -p /tmp/docker/$domain/$app

		# Generate enviroment
		local env_list
		for env in /tmp/docker/$domain/$app/ENV_*; do
			if [ -f $env ]; then
				env_list="$env_list -e $(basename ${env:4})=\"$(cat $env)\" ";
			fi
		done

		# Generate port forwards
		local port_list
		for p in /tmp/docker/$domain/$app/port[0-9]*; do
			if [ -f $p ]; then
				local p1=$(basename $p)
				local p2=$(cat $p)
				port_list="$port_list -p $p2:${p1:4} ";

				# Is the port in use?
				if netstat -ntap | grep -q $p2; then
					echo "Port $p2 is already in use, the old container will be undeployed before"
					echo "the deploy. This will cause a short service interruption."
					stop_container $domain $app $port
				fi
			fi
		done

		local http_port=80;
		if has_metadata $domain $app http-port; then
			http_port=$(get_metadata $domain $app http-port)
		fi

		echo -e "Deploying \e[1m$app.$domain\e[0m ($image):$http_port ⇄ $port"
		echo -e "Extra: $env_list $port_list"
		local app_id=$(docker run -d -p 127.0.0.1:$port:$http_port $env_list $port_list \
			--name app-$domain-$app-$port-$RANDOM $image)

		configure_nginx $domain $app $port
		save_metadata $domain $app id $app_id
		save_metadata $domain $app app $app
		save_metadata $domain $app port $port
		save_metadata $domain $app image $image
		save_metadata $domain $app domain $domain
	fi

	stop_container $domain $app $port
}

stop_container() {
	local domain=$1
	local app=$2
	local port=$3

	for id in $(docker ps --no-trunc | grep -v :$port | grep app-${domain}-${app}- | awk '{print $1}'); do
		echo "Stop container id:$id"
		docker stop $id > /dev/null
	done
}

undeploy_container() {
	local domain=$1
	local app=$2

	if [ x$(has_app $domain $app) == xyes ]; then
		echo -e "\e[1mUndeploy $app.$domain\e[0m"
		docker stop $(cat /tmp/docker/$domain/$app/id)
		rm -f /etc/nginx/conf.d/${domain}-${app}.conf
		nginx -s reload
		rm -f /tmp/docker/$domain/$app/id
	fi

}

remove_app() {
	local domain=$1
	local app=$2

	[ ! -d /tmp/docker/$domain/$app ] && return 1

	undeploy_container $domain $app
	echo "Remove $app.$domain"
	rm -rf /tmp/docker/$domain/$app
	if [ ! -d /tmp/docker/$domain/* ]; then
		echo "Remove $domain"
		rmdir /tmp/docker/$domain
	fi
}
