REMOTE_DEPLOY = "out/remote-deploy"
LOCAL_DEPLOY = "out/local-deploy"

test: merge
	@echo Run a few basic tests
	bash -n $(REMOTE_DEPLOY)
	bash -n $(LOCAL_DEPLOY)
	test -f /bin/bash

out:
	mkdir -p out

merge: out
	echo "#!/bin/bash" > $(REMOTE_DEPLOY)
	echo remote/* | for f in $$(cat -); do \
		echo "\n##\n## From $$f\n##\n"; \
		sed '/^#!/d' $$f; \
		done >> $(REMOTE_DEPLOY)
	echo "#!/bin/bash" > $(LOCAL_DEPLOY)
	echo local/* | for f in $$(cat -); do \
		echo "\n##\n## From $$f\n##\n"; \
		sed '/^#!/d' $$f; \
		done >> $(LOCAL_DEPLOY)

install: test
	@echo Install $(LOCAL_DEPLOY) to /usr/local/bin/shdeploy
	cp $(LOCAL_DEPLOY) /usr/local/bin/shdeploy
	@echo Install $(REMOTE_DEPLOY) to /var/lib/shdeploy/shremote
	mkdir -p /var/lib/shdeploy/
	cp $(REMOTE_DEPLOY) /var/lib/shdeploy/shremote
	sed -i 's/^REMOTE_DEPLOY_COMMAND=.*/REMOTE_DEPLOY_COMMAND=\/var\/lib\/shdeploy\/shremote/' \
		/usr/local/bin/shdeploy
	sed -i "s/^GIT_VERSION=.*/GIT_VERSION=`git rev-parse --short HEAD`/" \
		/usr/local/bin/shdeploy
	sed -i "s/^GIT_VERSION=.*/GIT_VERSION=`git rev-parse --short HEAD`/" \
		/var/lib/shdeploy/shremote

help-pages: test
	for command in none deploy undeploy remove meta install config status; do \
		echo "\n\n##" $$command; \
		echo '```'; \
		$(LOCAL_DEPLOY) $$command; \
		echo '```'; \
	done > HELP-PAGES.md
	sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" -i HELP-PAGES.md
	sed "s/## none/# shdeploy help pages/" -i HELP-PAGES.md
