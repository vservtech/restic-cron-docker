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

TODO

## More usage hints

- run `bun run shell` to get shell inside container

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
