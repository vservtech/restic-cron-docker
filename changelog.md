# Changelog

## 1.4.0 - 2025-11-15

- add rsync to the container

## 1.3.0 - 2025-11-15

- add sqlite3 to the container
- update alpine base image to 3.22.2

```bash
/opt/cron $ restic version
restic 0.18.0 compiled with go1.24.8 on linux/arm64

/opt/cron $ supercronic -version
v0.2.34

/opt/cron $ ssh -V
OpenSSH_10.0p2, OpenSSL 3.5.4 30 Sep 2025

/opt/cron $ sqlite3 --version
3.49.2 2025-05-07 10:39:52 17144570b0d96ae63cd6f3edca39e27ebd74925252bbaf6723bcb2f6b4861fb1 (64-bit)

/opt/cron $
```

## 1.2.2 - 2025-09-25

- check in prestart script if crontab file exists at all before validating
- add section in readme about restoring a backup with this container

## 1.2.1 - 2025-09-25

- add vim and nano to the container

1.2.0 - 2025-09-24

- update entrypoint script to support LOG_PREFIX variable for better maintenance
- update entrypoint script to support running a "prestart" script, if available.
  USAGE: COPY or bind this script into the container at
  `/usr/local/bin/prestart` and make it executable.

## 1.1.1 - 2025-09-23

- add HOST_USER and HOST_GROUP to entrypoint script - allows passing in the name
  of the user and group to run the container as => may fix the issue that ssh
  inside the container does not use the known_hosts and config files properly

## 1.1.0 - 2025-09-23

- remove duplicated user check block in docker-entrypoint
- add ssh into the container

Dependencies

- restic version: v0.18.0
- supercronic -version: v0.2.34
- ssh -V: OpenSSH_10.0p2, OpenSSL 3.5.1 1 Jul 2025

## 1.0.4 - 2025-09-23

- add missing DESIRED_UID to entrypoint script

## 1.0.3 - 2025-09-23

- update the docker-entrypoint to improve resilience

## 1.0.2 - 2025-09-23

- fix multi-arch build to include the right arch for supercronic (amd64 or
  arm64)

## 1.0.1 - 2025-09-23

- multi-arch build: for linux/amd64 and linux/arm64

## 1.0.0 - 2025-09-23

- initial release
- usage instructions tell how to
  - use crontab (running with supercronic)
  - use ash/bash scripts in crontab
  - checkout the container internals by opening a shell in the container
  - restic installed into the container
  - ability to run under a specific user/group
