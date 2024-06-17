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


| Mount Directory     | Description                   |
| ---                 | ---                           |
| `/entrypoint.d/`    | Initialization shell scripts  |
| `/var/lib/prosody/` | Prosody data directory        |


## Usage

Start and manage prosody using the following commands:

### Running the server

> [!IMPORTANT]
> Mount your prosody configuration file `prosody.cfg.lua` onto `/etc/prosody/prosody.cfg.lua`.


```bash
# Starting the server
docker run \
 --name prosody \
 -v data/:var/lib/prosody/ \
 -v config/prosody.cfg.lua:/etc/prosody/prosody.cfg.lua:ro \
 ghcr.io/error418/prosody:0.12.4

```

### Managing the server

```bash
# using prosodyctl, e.g. status
docker exec prosody prosodyctl status

```


