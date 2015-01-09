test:
	@echo Run a few basic tests
	bash -n local-deploy
	bash -n remote-deploy
	test -f /bin/bash

install: test
	@echo Install shdeploy to /usr/local/bin/
	cp local-deploy /usr/local/bin/shdeploy
	@echo Install shremote to /var/lib/shdeploy/
	mkdir -p /var/lib/shdeploy/
	cp remote-deploy /var/lib/shdeploy/shremote
	sed -i 's/^REMOTE_DEPLOY_COMMAND=.*/REMOTE_DEPLOY_COMMAND=\/var\/lib\/shdeploy\/shremote/' \
		/usr/local/bin/shdeploy
	sed -i "s/^GIT_VERSION=.*/GIT_VERSION=`git rev-parse --short HEAD`/" \
		/usr/local/bin/shdeploy
	sed -i "s/^GIT_VERSION=.*/GIT_VERSION=`git rev-parse --short HEAD`/" \
		/var/lib/shdeploy/shremote

help-pages:
	for command in none deploy undeploy remove meta install config; do \
		echo "\n\n#" $$command; \
		echo '```'; \
		./local-deploy $$command; \
		echo '```'; \
	done > HELP-PAGES.md
	sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" -i HELP-PAGES.md
