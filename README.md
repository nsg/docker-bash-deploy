# Docker Bash Deploy

This is a quick just-for-fun bash script that deploys Docker containers to servers running Ubuntu 14.04 LTS. It is fully usable but quite untested.

## Quick test

We need a file containing the servers, for example:
```
$ cat myservers
10.0.0.2
10.0.0.3
```
We assume that you can login as root w/o any password.

After that, install the needed applications on the target servers with:

`./deploy servers=myservers setup`

All done, deploy for example nginx:

`./deploy servers=myservers deploy webserver nginx`

This will download the image `nginx` to `10.0.0.2` and `10.0.0.3` and make it available on `webserver.stefanberggren.se`.

## All commands

### setup

Prepare the system and install all the needed applications.

### deploy name image

Deploy `image` to all systems with the name `name`.

### undeploy name

Undeploy/remove `name` from all systems.

### list

List all running containers on all servers.

### servers

List servers and various information.

### set [host] app key value

Set custom params to host(s). Set the parameter `foo` with the value `bar` to the app `myapp`to all hosts.

```
./deploy set myapp foo bar
```

The same thing, but limit it to just one host.

```
./deploy set 10.0.0.2 myapp foo bar
```

### get app

Get all custom params from a app.

```
./deploy get myapp
```

## Configuration

The configuration file is `~/.docker-bash-deploy`

### server

Define your servers here, no need to define the server list on the
command line. For example `./deploy servers=myservers list` will just be `./deploy list`.

```
servers=10.0.0.2 10.0.0.3
```
