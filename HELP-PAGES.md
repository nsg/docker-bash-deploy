

# shdeploy help pages
```
local-deploy based on commit HEAD
This is a simple deployment tool written in bash.

usage:      [deploy|undeploy|remove|meta|list|install|config|
            status] [app.domain.ltd] [-DcH]

  -D        Show debug messages
  -c path   Path to config file
            Default is ~/.docker-bash-deploy
  -H host   Provide a list of hosts on the commandline
            This overloads settings from -c

  app.domain.ltd is optional and are identical to -a app -o domain.ltd.
  It is only a convenience shortcut that only make sense to use on
  commands that support -a and -o.

Example:

To limit a deploy to a specific host
local-deploy deploy -H 10.0.0.2 ...

Specify a custom config file
local-deploy deploy -c ../myfile ...
```


## deploy
```
local-deploy based on commit HEAD
This is a simple deployment tool written in bash.

usage:    local-deploy deploy -[aio]

Deploy a new, or replace a container.

  -a      The name of the app
  -i      Name of the image
  -o      The domain

Example:

To deploy the image nginx on test.example.com:
local-deploy deploy -i nginx -a test -o example.com
```


## undeploy
```
local-deploy based on commit HEAD
This is a simple deployment tool written in bash.

usage:    local-deploy undeploy -[ao]

Undeploy a container.

  -a      The name of the app
  -o      The domain

Example:

To undeploy test.example.com:
local-deploy undeploy -a test -o example.com
```


## remove
```
local-deploy based on commit HEAD
This is a simple deployment tool written in bash.

usage:    local-deploy remove -[ao]

Remove a container and all metadata.

  -a      The name of the app
  -o      The domain

Example:

To remove test.example.com:
local-deploy remove -a test -o example.com
```


## meta
```
local-deploy based on commit HEAD
This is a simple deployment tool written in bash.

usage:    local-deploy meta -[aokv]
usage:    local-deploy meta -[ao]

Set or get metadata to an app.

  -a      The name of the app
  -o      The domain
  -k      Name of the key
  -v      Name of the value

Set the value (-v) to false to remove a key.

Special keys:

  default      This is the default nginx container.
  ENV_*        To set the Docker env 'FOO', set ENV_FOO.
  port*        To forward port 22 inside the container
               to 4722 on the host, set port22 to 4711.

Examples:

To get metadata for test.example.com:
local-deploy meta -a test -o example.com

Set metadata for test.example.com:
local-deploy meta -a test -o example.com -k mykey -v myvalue
```


## install
```
local-deploy based on commit HEAD
This is a simple deployment tool written in bash.

usage:    local-deploy install [full|remote|vpn]

  full      Check installed apps and do all below.
  remote    Only update the remote script.
  vpn       Only update the vpn config.

Setup the servers, install needed applications.

First time using this tool? You need to have passwordless root
access to the server. Verify that with 'ssh root@example.com'.
Do a full install with local-deploy install full.
```


## config
```
local-deploy based on commit HEAD
This is a simple deployment tool written in bash.

usage:    local-deploy config show

  show      Show loaded config.

Example configuration file:

  servers=10.0.0.2 example.com
  domain=example.com
```


## status
```
local-deploy based on commit HEAD
This is a simple deployment tool written in bash.

usage:    local-deploy status [vpn|fs]

  vpn       Show VPN status.
  fs        Show filesystem status.

Show server status.
```
