#!/bin/bash

set -uexo pipefail

case $(uname -m) in
  x86_64 | amd64)
    platform=linux/amd64
    ;;
  arm64 | aarch64)
    platform=linux/arm64
    ;;
  *)
    echo >&2
    echo "Unsupported architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

# build for the current platform
docker buildx build \
  --platform=$platform \
  --progress=plain \
  --cache-from=elijahru/lintball \
  --tag=elijahru/lintball:latest \
  --target=lintball-latest \
  --load \
  .

# Lint the codebase
docker-compose run check

# Build the test image
docker buildx build \
  --platform=$platform \
  --progress=plain \
  --cache-from=elijahru/lintball \
  --tag=elijahru/lintball:test \
  --target=lintball-test \
  --load \
  .

# Run the tests
docker-compose run test
