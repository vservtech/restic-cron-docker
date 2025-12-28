# Agent Guidelines for restic-cron-docker

This document provides guidelines for AI coding agents working on this Docker-based restic backup scheduler project.

## Project Overview

A Docker container that runs restic backups on a cron schedule using supercronic. The container supports bash/ash/bun scripts, runs as configurable user/group, and includes tools like restic, postgresql-client, mysql-client, sqlite3, rsync, and ssh.

## Build, Test & Development Commands

### Docker Operations
```bash
# Build and run container interactively
bun run dev                    # docker compose up --build --remove-orphans

# Start container in background
bun run start                  # docker compose up -d --build --remove-orphans

# Stop container
bun run stop                   # docker compose down

# Get shell access (ash)
bun run shell                  # docker compose run --build --remove-orphans restic-cron ash

# Check installed tool versions
bun run versions               # Runs versions.sh inside container
```

### Building & Deploying Images
```bash
# Build local image with version tags
bun run build                  # Tags with version from package.json + latest

# Build for specific architecture
bun run build-amd64            # Build for linux/amd64 only

# Setup buildx for multi-arch builds
bun run setup-buildx           # Create buildx builder
bun run use-buildx             # Switch to buildx builder

# Deploy multi-arch to Docker Hub
bun run deployx                # Build & push linux/amd64 + linux/arm64
```

### Testing
- No automated test suite currently exists
- Manual testing: Use `bun run dev` and observe cron job execution in logs
- Test scripts are in `test/` directory (bash-demo.sh, ash-demo.sh, bun-demo.ts)
- Verify crontab syntax: Container runs prestart validation automatically

## Code Style Guidelines

### Shell Scripts (sh/bash)

**File Headers:**
```bash
#!/bin/sh          # For POSIX-compliant scripts (alpine default)
#!/bin/bash        # For bash-specific features
set -eu            # Exit on error, fail on undefined variables
```

**Naming Conventions:**
- Variables: `UPPER_SNAKE_CASE` for environment variables and constants
- Local variables: `lower_snake_case`
- Functions: `lower_snake_case`
- Log prefixes: Use descriptive `LOG_PREFIX` variable

**Error Handling:**
```bash
# Always check command success for critical operations
if ! command_that_might_fail; then
    echo "${LOG_PREFIX}: ERROR: descriptive message" >&2
    exit 1
fi

# Use conditional execution for non-critical checks
getent group "${GID}" >/dev/null 2>&1 || addgroup -g "${GID}" "${GROUP}"
```

**Output:**
- Use `echo` for informational messages
- Redirect errors to stderr: `>&2`
- Prefix log messages with `${LOG_PREFIX}:` for clarity
- Use visual indicators: `✓✓✓` for success, `✗✗✗` for errors

### TypeScript/Bun Scripts

**File Headers:**
```typescript
#!/usr/bin/env bun
```

**Style:**
- Use modern ES6+ syntax
- Prefer `const` over `let`, avoid `var`
- Use template literals for string interpolation
- ISO 8601 dates: `new Date().toISOString()`

### Dockerfile

**Structure:**
- Multi-stage builds not used (single-stage alpine-based image)
- Group related RUN commands to minimize layers
- Use `--no-cache` for apk installations
- Set environment variables before using them
- Use ARG for build-time variables (e.g., TARGETARCH)

**Conventions:**
- Comments explain WHY, not WHAT
- Verify checksums for downloaded binaries (SHA1/SHA256)
- Install dependencies in logical groups
- Set WORKDIR and create directories explicitly
- Make scripts executable: `chmod +x`

## File Organization

```
/
├── src/                    # Source scripts for container
│   ├── docker-entrypoint.sh   # Main entrypoint (user/group setup)
│   └── docker-prestart.sh     # Validation script (crontab check)
├── test/                   # Test scripts and example crontab
├── dev/                    # Development utilities (versions.sh)
├── Dockerfile              # Container definition
├── compose.yml             # Docker Compose config
├── package.json            # npm scripts and metadata
└── README.md               # User documentation
```

## Important Conventions

### Container Behavior
- Default user: root (unless HOST_UID/HOST_GID specified)
- Working directory: `/opt/cron`
- Entrypoint creates users/groups dynamically if needed
- Prestart script validates crontab syntax before starting
- Uses `su-exec` to drop privileges (not `gosu` or `sudo`)

### Environment Variables
- `HOST_UID` / `HOST_GID`: Run container as specific user/group
- `HOST_USER` / `HOST_GROUP`: Custom user/group names (default: appuser/appgroup)
- `CHOWN_WORKDIR`: Set to `true` to chown `/opt/cron` to the container user (default: false)
- `CRON_DIR`: Working directory path (default: /opt/cron)
- `BUN_INSTALL`: Bun installation path (default: /opt/bun)

### Volume Mounts
- **Required:** `./crontab:/opt/cron/crontab` (cron schedule)
- **Optional:** Mount scripts into `/opt/cron/` for execution
- Scripts must be executable (`chmod +x`) on host
- Use absolute paths in crontab entries

### Crontab Format
- Uses supercronic (golang cronexpr)
- Supports seconds-based resolution (7 fields vs standard 5)
- Format: `Seconds Minutes Hours Day Month DayOfWeek Year`
- Example: `*/1 * * * * * *` (every second)
- Use `-passthrough-logs` flag for proper log output

## Error Handling Patterns

### Shell Scripts
```bash
# Validate required files exist
if [ ! -f /path/to/file ]; then
    echo "ERROR: File not found" >&2
    exit 1
fi

# Check command availability
if ! command -v tool >/dev/null 2>&1; then
    echo "ERROR: tool not installed" >&2
    exit 1
fi

# Validate user/group operations
if ! adduser -D -u "${UID}" "${USER}"; then
    echo "ERROR: adduser failed" >&2
    exit 1
fi
```

## Documentation Standards

- Update CHANGELOG.md for every release with version, date, changes, and tool versions
- Update package.json version before release
- README.md contains user-facing documentation
- Code comments explain WHY, not WHAT
- Use examples in documentation (crontab, docker-compose snippets)

## Release Process

1. Check for alpine base image updates
2. Run `bun versions` to get current tool versions
3. Update package.json version (semver)
4. Update CHANGELOG.md with changes and tool versions
5. Switch to buildx: `bun use-buildx`
6. Deploy: `bun deployx` (builds & pushes multi-arch)
7. Verify on Docker Hub
8. Commit and tag in git

## Common Pitfalls

- **Don't** use `cd` in crontab entries; use absolute paths
- **Don't** forget to make scripts executable (`chmod +x`)
- **Don't** run container with `user:` in compose.yml (breaks entrypoint)
- **Don't** mount scripts outside `/opt/cron/` (permission issues)
- **Always** validate crontab syntax (prestart does this automatically)
- **Always** use `set -eu` in shell scripts for safety
- **Always** quote paths with spaces in shell commands
