# Prosody Container Image

This repository contains a non-root container image for Prosody.

It contains:

* [Prosody IM](https://prosody.im/)
* [LuaRocks](https://luarocks.org/) (required for `prosodyctl install` commands)
* Support for initialization scripts


## Initialization Scripts

> [!IMPORTANT]
> Scripts are run with the user the container starts with.
> The default user is the non-root user `prosody`

Container configuration can be customized using initialization scripts mounted to `/entrypoint.d/`. Scripts in this directory will be executed when launching the container.

This can for example be used for installing prosody modules using `prosodyctl install`.


## Volume Mounts

> [!TIP]
> Mount your prosody modules into the directory specified in your Prosody configuration to speed up your startup.


| Mount Directory     | Description                       |
| ---                 | ---                               |
| `/entrypoint.d/`    | Initialization shell scripts      |
| `/var/lib/prosody/` | Prosody data directory            |
| `/etc/prosody/`     | Prosody configuration directory   |


## Usage

Start and manage prosody using the following commands:

### Running the server

> [!IMPORTANT]
> Adjust the volume mounts according to your system setup.


```bash
docker run \
 --name prosody \
 -P \
 -v ./config/prosody.cfg.lua:/etc/prosody/prosody.cfg.lua:ro \
 -v [DATA_DIRECTORY]/:var/lib/prosody/ \
 -v /etc/letsencrypt/live/:/etc/letsencrypt/live/:ro \
 --restart=unless-stopped \
 ghcr.io/error418/prosody:0.12.4

```

### Managing the server

Use `docker exec` to run commands inside the container.

```bash
docker exec prosody prosodyctl status

```

### Let's Encrypt

Add the following renewal hook to letsencrypt: 

`/etc/letsencrypt/renewal-hooks/deploy/prosody.sh`

```bash
#!/bin/sh

docker exec -u0 prosody prosodyctl --root cert import /etc/letsencrypt/live
```

The certbot directory `/etc/letsencrypt/live` needs to be mounted in the running container.
