#!/bin/bash

show_help() {
	echo -e "\e[1m`basename $0`\e[0m based on commit $GIT_VERSION"
	echo -e "This is a simple deployment tool written in bash."
	echo
	case $1 in
		deploy)
			echo -e "usage:    `basename $0` \e[1mdeploy -[aio]\e[0m"
			echo
			echo -e "Deploy a new, or replace a container."
			echo
			echo -e "  \e[1m-a\e[0m      The name of the app"
			echo -e "  \e[1m-i\e[0m      Name of the image"
			echo -e "  \e[1m-o\e[0m      The domain"
			echo
			echo -e "Example:"
			echo
			echo -e "To deploy the image nginx on test.example.com:"
			echo -e "`basename $0` deploy -i nginx -a test -o example.com"
			;;
		undeploy)
			echo -e "usage:    `basename $0` \e[1mundeploy -[ao]\e[0m"
			echo
			echo -e "Undeploy a container."
			echo
			echo -e "  \e[1m-a\e[0m      The name of the app"
			echo -e "  \e[1m-o\e[0m      The domain"
			echo
			echo -e "Example:"
			echo
			echo -e "To undeploy test.example.com:"
			echo -e "`basename $0` undeploy -a test -o example.com"
			;;
		remove)
			echo -e "usage:    `basename $0` \e[1mremove -[ao]\e[0m"
			echo
			echo -e "Remove a container and all metadata."
			echo
			echo -e "  \e[1m-a\e[0m      The name of the app"
			echo -e "  \e[1m-o\e[0m      The domain"
			echo
			echo -e "Example:"
			echo
			echo -e "To remove test.example.com:"
			echo -e "`basename $0` remove -a test -o example.com"
			;;
		meta)
			echo -e "usage:    `basename $0` \e[1mmeta -[aokv]\e[0m"
			echo -e "usage:    `basename $0` \e[1mmeta -[ao]\e[0m"
			echo
			echo -e "Set or get metadata to an app."
			echo
			echo -e "  \e[1m-a\e[0m      The name of the app"
			echo -e "  \e[1m-o\e[0m      The domain"
			echo -e "  \e[1m-k\e[0m      Name of the key"
			echo -e "  \e[1m-v\e[0m      Name of the value"
			echo
			echo -e "Set the value (-v) to false to remove a key."
			echo
			echo -e "Special keys:"
			echo
			echo -e "  \e[1mdefault\e[0m      This is the default nginx container."
			echo -e "  \e[1mENV_*\e[0m        To set the Docker env 'FOO', set ENV_FOO."
			echo -e "  \e[1mport*\e[0m        To forward port 22 inside the container"
			echo -e "               to 4722 on the host, set port22 to 4711."
			echo
			echo -e "Examples:"
			echo
			echo -e "To get metadata for test.example.com:"
			echo -e "`basename $0` meta -a test -o example.com"
			echo
			echo -e "Set metadata for test.example.com:"
			echo -e "`basename $0` meta -a test -o example.com -k mykey -v myvalue"
			;;
		install)
			echo -e "usage:    `basename $0` \e[1minstall [full|remote|vpn]\e[0m"
			echo
			echo -e "  \e[1mfull\e[0m      Check installed apps and do all below."
			echo -e "  \e[1mremote\e[0m    Only update the remote script."
			echo -e "  \e[1mvpn\e[0m       Only update the vpn config."
			echo
			echo -e "Setup the servers, install needed applications."
			echo
			echo -e "First time using this tool? You need to have passwordless root"
			echo -e "access to the server. Verify that with 'ssh root@example.com'."
			echo -e "Do a full install with `basename $0` install full."
			;;
		status)
			echo -e "usage:    `basename $0` \e[1mstatus [vpn|fs]\e[0m"
			echo
			echo -e "  \e[1mvpn\e[0m       Show VPN status."
			echo -e "  \e[1mfs\e[0m        Show filesystem status."
			echo
			echo -e "Show server status."
			;;
		config)
			echo -e "usage:    `basename $0` \e[1mconfig show\e[0m"
			echo
			echo -e "  \e[1mshow\e[0m      Show loaded config."
			echo
			echo -e "Example configuration file:"
			echo
			echo -e "  servers=10.0.0.2 example.com"
			echo -e "  domain=example.com"
			;;
		*)
			echo -e "usage:      \e[1m[deploy|undeploy|remove|meta|list|install|config|\e[0m"
			echo -e "            \e[1mstatus] [app.domain.ltd] [-DcH]\e[0m"
			echo
			echo -e "  \e[1m-D\e[0m        Show debug messages"
			echo -e "  \e[1m-c path\e[0m   Path to config file"
			echo -e "            Default is ~/.docker-bash-deploy"
			echo -e "  \e[1m-H host\e[0m   Provide a list of hosts on the commandline"
			echo -e "            This overloads settings from -c"
			echo
			echo -e "  \e[1mapp.domain.ltd\e[0m is optional and are identical to -a app -o domain.ltd."
			echo -e "  It is only a convenience shortcut that only make sense to use on"
			echo -e "  commands that support -a and -o."
			echo
			echo -e "Example:"
			echo
			echo -e "To limit a deploy to a specific host"
			echo -e "`basename $0` deploy \e[1m-H 10.0.0.2\e[0m" ...
			echo
			echo -e "Specify a custom config file"
			echo -e "`basename $0` deploy \e[1m-c ../myfile\e[0m" ...
	esac

	exit 0
}

