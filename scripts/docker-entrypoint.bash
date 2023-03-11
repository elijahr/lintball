#!/bin/bash

set -ueo pipefail

# shellcheck disable=SC1090
source ~/.profile

exec "$@"
