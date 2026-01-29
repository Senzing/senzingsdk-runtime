# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This repository builds a Docker base image (`senzing/senzingsdk-runtime`) containing the Senzing SDK V4 runtime libraries. The image is intended to be used as a base image (via `FROM senzing/senzingsdk-runtime`) rather than run directly as a container.

**Important:** This is for Senzing SDK V4 only, not compatible with Senzing API V3.

## Build Commands

```bash
# Build the Docker image
make docker-build

# Run Docker tests (verifies Senzing files are correctly installed)
make docker-test

# Clean up built images
make clean

# List all make targets
make help
```

## Key Files

- `Dockerfile` - Defines the base image build process:
  - Base: Debian 13 slim
  - Installs `senzingsdk-runtime` package from Senzing APT repository
  - Sets `LD_LIBRARY_PATH=/opt/senzing/er/lib`
  - Runs as root (downstream images should switch to non-root user)
  - Contains `REFRESHED_AT` date that must be updated when base image changes

- `.github/scripts/docker_test_script.sh` - Verification script run by `make docker-test`:
  - Checks `LD_LIBRARY_PATH` is set
  - Verifies `/opt/senzing/er/g2BuildVersion.json` exists
  - Verifies `/opt/senzing/data/libpostal/data_version` exists
  - Validates build version matches installed package

## CI/CD Workflows

- `docker-build-container.yaml` - Builds against both production and staging APT repositories on PRs and daily schedule
- `verify-dockerfile-refreshed-at-updated.yaml` - Ensures `REFRESHED_AT` date is updated when base image is updated
- `lint-workflows.yaml` - Runs workflow linting via `senzing-factory/build-resources`

## Linting

Dockerfile linting can be done manually:
```bash
docker run -it --rm --privileged \
  --volume $PWD:/root/ \
  projectatomic/dockerfile-lint \
  dockerfile_lint -f Dockerfile
```

Or use the online linter at https://www.fromlatest.io

## Dockerfile Update Notes

When updating the base image digest in `Dockerfile`:
1. Update the `BASE_IMAGE` ARG with new digest
2. Update `REFRESHED_AT` date to current date (YYYY-MM-DD format)
3. The `verify-dockerfile-refreshed-at-updated.yaml` workflow will fail if these are not kept in sync
