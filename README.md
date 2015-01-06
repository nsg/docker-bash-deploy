# shdeploy

This is a quick just-for-fun bash script that deploys Docker containers to servers running Ubuntu 14.04 LTS. It is fully usable but quite untested.

## Install

Type `make install` to install it. The command will be called `shdeploy`
To test the command w/o a installation use `./local-deploy`.

## Quick test

We need a file containing the servers, for example:
```
$ cat myservers
server=10.0.0.2 10.0.0.3
```
We assume that you can login as root w/o any password.

After that, install the needed applications on the target servers with:

`shdeploy -c myservers -I`

All done, deploy for example nginx:

`shdeploy -c myservers -d webserver -i nginx -o example.com`

This will download the image `nginx` to `10.0.0.2` and `10.0.0.3` and make it available on `webserver.example.com`.

## More?

Type `shdeploy -h`

## Examples

### My blog

First time, we need to set the key `default` to set the container as the default nginx site
(so that both nsg.cc and www.nsg.cc will work).

```
shdeploy -a www -o nsg.cc -k default -v true
```

Time to deploy it...

```
shdeploy -d www -i nsgb/blog:1.3 -o nsg.cc
```
