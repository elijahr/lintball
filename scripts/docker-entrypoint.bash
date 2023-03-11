#!/bin/bash

set -ueo pipefail

PATH="/lintball/bin:$PATH"
export PATH

# shellcheck disable=SC1090
source ~/.profile

exec "$@"
