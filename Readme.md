# Restic Cron Docker

This repo contains a dockerfile which allows running a restic cron job inside a
docker container.\
[Link to Github](https://github.com/vservtech/restic-cron-docker)

**[CHANGELOG](https://github.com/vservtech/restic-cron-docker/blob/main/CHANGELOG.md)**

## Why?

I want to be able to run restic backups on a schedule. This image is intended as
sidecar to other services. It should mount the same volumes as the main service
and run the restic backups on a schedule.

## How to use this docker image

### How to use `supercronic`

Instructions: https://github.com/aptible/supercronic

```shell
supercronic -help
supercronic -version
```

### How to use `restic`

Preparation: Create a restic repository, if not already done. See:
https://restic.readthedocs.io/en/latest/030_preparing_a_new_repo.html

Backup some data: https://restic.readthedocs.io/en/latest/040_backup.html

## Get Shell Access in the container

- run `bun run shell` to get shell inside container
- from outside: the container is based on alpine, so the shell to start is
  `/bin/ash`

## For Developers: New Image release to docker

1. Check for updates of the base alpine image: see here for new versions:
   https://hub.docker.com/_/alpine/tags
2. Test with `bun run shell` to get shell access into the container
3. Get new tool versions and update Changelog.md
   1. `restic version`
4. Sign-off new version for npm package
5. Deploy with `bun run deploy` (runs build, tag:latest and push:version and
   push:latest)
6. Commit and tag the release in git
