# shdeploy

This is a quick just-for-fun bash script that deploys Docker containers to servers running Ubuntu 14.04 LTS. It is fully usable but quite untested.

The script has two parts, the local script and a remote script that is installed on the remote systems. All needed dependencies (like docker, nginx, …) are installed by the script. The only local dependency is ssh (and make and git if you like to install this from source), so this will run on Linux, OS X, \*BSD and so on... You need Linux on the server, and only Ubuntu 14.04 LTS is supported atm (this is easly extended).



## Install

```
git clone https://github.com/nsg/shdeploy.git
cd shdeploy
sudo make install
```

The command will be called `shdeploy`
To test the command w/o a installation use `./local-deploy`.

## Quick test

We need a file containing the servers and our default domain, for example:
```
$ cat myservers
server=10.0.0.2 10.0.0.3
domain=example.com
```
We assume that: 
* You can login as root w/o any password to both servers.
* The DNS \*.example.com points to at least one of the servers.

After that, install the needed applications on the target servers with:

`shdeploy install full -c myservers`

All done, deploy for example nginx:

`shdeploy deploy -c myservers -a webserver -i nginx`

This will download the image `nginx` to `10.0.0.2` and `10.0.0.3` and make it available on `webserver.example.com`.

## More?

Type `shdeploy` for help, or see [HELP-PAGES](HELP-PAGES.md).

## Examples

### My blog

First time, we need to set the key `default` to set the container as the default nginx site
(so that both nsg.cc and www.nsg.cc will work).

```
shdeploy meta www.nsg.cc -k default -v true
```

Time to deploy it...

```
shdeploy deploy www.nsg.cc -i nsgb/blog:1.3
```
