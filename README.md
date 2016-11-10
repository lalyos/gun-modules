This repo helps to create 
## install gun

```
curl -Lk https://github.com/gliderlabs/glidergun/releases/download/v0.1.0/glidergun_0.1.0_Darwin_x86_64.tgz | tar -xz -C /usr/local/bin
```

## install docker-machine module

```
gun :get github.com/sequenceiq/gun-modules/cmds
echo export DEPS_REPO=https://raw.githubusercontent.com/lalyos/glidergun-rack/master/index >> Gunfile
```

## create the xhyve VM

```

gun machine create
```
it will asks for admin password for giving `sudo` rights to docker-machine driver

## Changing file sharing

By default shyve vm is created with `--xhyve-experimental-nfs-share`, but some systems might not work with it.

To check if the 

```
date | tee delme.txt && docker run -v $PWD:/data alpine cat /data/delme.txt
```


```
echo 'export MACHINE_OPTS="--xhyve-virtio-9p"' >> Profile
```

# tl;dr

todo: diff between:
- b2d
- docker-machine with virtualbox
- docker-machine with xhyve
- docker for mac
