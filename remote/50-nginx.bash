#!/bin/bash

configure_nginx() {
	local domain=$1
	local app=$2
	local port=$3
	
	if [ $(get_metadata $domain $app default) ]; then
		listen="80 default";
	else
		listen=80;
	fi

	echo "
	server {
		listen $listen;
		server_name ${app}.$domain;
		location / {
			proxy_pass http://127.0.0.1:$port;
		}
	}
	" > /etc/nginx/conf.d/${domain}-${app}.conf
	nginx -s reload
}

