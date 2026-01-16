# Agent Guidelines for restic-cron-docker

This file defines how agentic coding assistants should work in this repo.

## Project Overview

This repository builds a Docker image that runs restic backups on a cron schedule
using supercronic. The container supports ash/bash/bun scripts, can run as a
configurable user/group, and ships tools like restic, rsync, ssh, and database
clients.

## Build, Run, and Test Commands

### Local Docker workflow
```bash
bun run dev                    # docker compose up --build --remove-orphans
bun run start                  # docker compose up -d --build --remove-orphans
bun run stop                   # docker compose down
bun run shell                  # docker compose run --build --remove-orphans restic-cron ash
bun run versions               # run versions.sh inside the container
```

### Build and deploy images
```bash
bun run build                  # docker build, tag version + latest
bun run build-amd64            # buildx for linux/amd64
bun run setup-buildx           # create buildx builder
bun run use-buildx             # switch to buildx builder
bun run deployx                # buildx push linux/amd64 + linux/arm64
```

### Testing
- No automated test suite exists in this repo.
- Manual smoke tests:
  - `bun run dev` and watch logs for cron execution.
  - `bun run test:root` or `bun run test:non-root` (docker compose with env files).
- Single-test guidance:
  - There is no single-test runner. To isolate behavior, prefer
    `bun run test:root` or `bun run test:non-root` and limit changes to one
    script in `test/`, or open a shell with `bun run shell` and run a specific
    script manually.

## Code Style Guidelines

### Shell scripts (sh/bash)
- Use `#!/bin/sh` for POSIX/Alpine, `#!/bin/bash` only when needed.
- Start with `set -eu` for strict error handling.
- Variables:
  - Env/constants: `UPPER_SNAKE_CASE`
  - Locals: `lower_snake_case`
- Functions: `lower_snake_case`.
- Use a `LOG_PREFIX` and prefix logs with it.
- Send errors to stderr: `>&2`.
- Always quote variables and paths.
- Avoid bashisms in `sh` scripts.

### Error handling patterns
```sh
if ! command_that_might_fail; then
  echo "${LOG_PREFIX}: ERROR: description" >&2
  exit 1
fi

getent group "${GID}" >/dev/null 2>&1 || addgroup -g "${GID}" "${GROUP}"
```

### TypeScript/Bun scripts
- Shebang: `#!/usr/bin/env bun`.
- Prefer `const` and template literals.
- Use ISO 8601 timestamps: `new Date().toISOString()`.

### Dockerfile
- Single-stage, Alpine-based image.
- Group related `RUN` commands to reduce layers.
- Use `--no-cache` for `apk add`.
- Set `ENV` before use, and use `ARG` for build-time values.
- Comments explain why, not what.
- Make scripts executable with `chmod +x`.

## Repository Layout

```
/
├── src/                  # Container scripts
│   ├── docker-entrypoint.sh
│   └── docker-prestart.sh
├── test/                 # Demo/test scripts and crontab
├── dev/                  # Development utilities
├── Dockerfile            # Image definition
├── compose.yml           # Docker Compose config
├── package.json          # Scripts + metadata
└── README.md             # User documentation
```

## Container Behavior and Conventions

- Default user is root unless `HOST_UID`/`HOST_GID` is set.
- Working directory is `/opt/cron`.
- Entrypoint may create user/group and then drops privileges via `su-exec`.
- Prestart script validates crontab syntax with supercronic.
- Do not run the container with `user:` in `compose.yml`.

### Environment variables
- `HOST_UID` / `HOST_GID`: desired UID/GID.
- `HOST_USER` / `HOST_GROUP`: user/group names (defaults: appuser/appgroup).
- `CHOWN_WORKDIR`: `true` to chown `/opt/cron` (default: false).
- `CRON_DIR`: working directory path (default: `/opt/cron`).
- `BUN_INSTALL`: bun install path (default: `/opt/bun`).

### Volume mounts
- Required: `./crontab:/opt/cron/crontab`.
- Mount scripts into `/opt/cron/` and ensure they are executable.
- Always use absolute paths in crontab entries.

### Crontab format
- Uses supercronic (cronexpr) with optional seconds.
- Format: `Seconds Minutes Hours Day Month DayOfWeek Year`.
- Example: `*/1 * * * * * *` (every second).

## Linting and Formatting

- No lint/format scripts are configured in `package.json`.
- For shell scripts, run `shellcheck` locally if available.
- Keep formatting consistent with existing files; avoid reformatting unrelated
  lines.

## Release Process (High Level)

1. Check for new Alpine base image tags.
2. Run `bun run versions` and update `CHANGELOG.md`.
3. Bump `package.json` version.
4. Build/push via `bun run deployx` after `bun run use-buildx`.
5. Verify Docker Hub tags and then commit/tag.

## Cursor/Copilot Rules

- No `.cursor/rules`, `.cursorrules`, or `.github/copilot-instructions.md` were
  found in this repository. Follow this `AGENTS.md` as the primary guidance.
