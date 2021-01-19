#!/usr/bin/env bash

set -ueo pipefail

if [ -n "${CI:-}" ]; then
  # on CI systems show debug output
  set -x
fi

LB_DIR="${1:-"${HOME}/.lintball"}"
# shellcheck source=SCRIPTDIR/lib/install.bash
source "${LB_DIR}/lib/install.bash"

update_repo

# After update, re-source lib/install.bash for new finish_update function
# definition.
# shellcheck source=SCRIPTDIR/lib/install.bash
source "${LB_DIR}/lib/install.bash"

finish_update
