#!/bin/bash

set -ueo pipefail

PATH="/lintball/bin:$PATH"
export PATH

LINTBALL_DIR="/lintball"
export LINTBALL_DIR

# shellcheck disable=SC1090
source ~/.profile

exec "$@"
