# Adofox

Adofox runs Firefox ESR 52.9.0 and Adobe Flash Player 32.0.0.363 (NPAPI) in a Docker container.

## Run

```sh
docker build -t adofox .
./adofox
```

The launcher mounts the host directory `~/.adofox` at `/home/ffuser` in the container. Firefox saves its profile there.
The launcher gives each container a separate D-Bus machine ID.

Use this browser only for trusted legacy sites. Firefox and Flash no longer receive security updates.
