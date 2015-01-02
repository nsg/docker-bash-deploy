# Docker Bash Deploy

This is a quick just-for-fun bash script that deploys Docker containers to servers running Ubuntu 14.04 LTS. It is fully usable but quite untested.

## Quick test

We need a file containing the servers, for example:
```
$ cat myservers
server=10.0.0.2 10.0.0.3
```
We assume that you can login as root w/o any password.

After that, install the needed applications on the target servers with:

`./local-deploy -c myservers -I`

All done, deploy for example nginx:

`./local-deploy -c myservers -d webserver -i nginx -o example.com`

This will download the image `nginx` to `10.0.0.2` and `10.0.0.3` and make it available on `webserver.example.com`.

## More?

Type `./local-deploy -h`
