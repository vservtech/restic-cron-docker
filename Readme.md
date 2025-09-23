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

1. Place a crontab file somewhere in your source code, for example into
   `src/crontab` (see [Chrontab content](#chrontab-content) below)
2. Mount this into the container as a volume, example here for docker compose:
   IMPORTANT: The path inside the container must be `/opt/cron/crontab`!
   ```yaml
   volumes:
      - ./src/crontab:/opt/cron/crontab
   ```
3. Optional: Set the user and group under which the container should run:
   ```yaml
   restic-cron:
      image: vservtech/restic-cron-docker:latest
      volumes:
         - ./src/crontab:/opt/cron/crontab
      user: "${MY_UID}:${MY_GID}"
   ```
4. Run the container:
   ```shell
   docker compose up -d
   ```

### Chrontab content

```
# This crontab is evaluated by golangs cronexpr inside supercronic
# supports seconds-based resolution (normal cronjobs are minutes-based)

# Allowed fields: https://github.com/aptible/supercronic/tree/master/cronexpr#implementation
# Field name     Mandatory?   Allowed values    Allowed special characters
# ----------     ----------   --------------    --------------------------
# Seconds        No           0-59              * / , -
# Minutes        Yes          0-59              * / , -
# Hours          Yes          0-23              * / , -
# Day of month   Yes          1-31              * / , - L W
# Month          Yes          1-12 or JAN-DEC   * / , -
# Day of week    Yes          0-6 or SUN-SAT    * / , - L #
# Year           No           1970–2099         * / , -

# Run every minute
*/1 * * * * echo "hello every minute: $(date -u + \"%Y-%m-%dT%H:%M:%SZ\")"

# Run every second
*/1 * * * * * * echo "hello every second: $(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Run once every hour
# @hourly echo "$SOME_HOURLY_JOB"
```

### How to use ash/bash scripts in crontab

You can use ash (default on alpine linux) or bash scripts in your crontab.

1. Create the scripts in your repo, for example `src/bash-demo.sh`
   ```bash
   echo "hello from bash $(date -u +"%Y-%m-%dT%H:%M:%SZ")"
   ```
2. Mount the scripts into the container as a volume, example here for docker
   compose: IMPORTANT: The path inside the container should be inside
   `/opt/cron/` because this folder is configured for variable user/group the
   container could be running under!
   ```yaml
   volumes:
      - ./src/bash-demo.sh:/opt/cron/bash-demo.sh
   ```
3. Adjust your crontab to run the script: IMPORTANT: Use the absolute path to
   the script inside the container to avoid PATH issues!
   ```
   */1 * * * * * * /opt/cron/bash-demo.sh
   ```
4. Make sure the script is executable in your repo: `chmod +x src/bash-demo.sh`
5. Make sure the script is owned by the user running the container!
6. Start the container interactively and see the logs.

### DeepDive: How to use `supercronic`

Instructions: https://github.com/aptible/supercronic

```shell
supercronic -help
supercronic -version
```

### DeepDive: How to use `restic`

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

## Ideas

- TODO: Evaluate adding bun into this image for simple (JavaScript-)scripting:
  https://bun.com/docs/runtime/shell#sh-file-loader
