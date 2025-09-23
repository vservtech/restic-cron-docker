# Changelog

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
